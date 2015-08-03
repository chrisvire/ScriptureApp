//
//  SearchTableViewController.swift
//  ScriptureApp
//
//  Created by David Moore on 7/8/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit
import WebKit

class SearchTableViewController: UITableViewController {
    var searchHandler = AISSearchHandler()
    var mSearchString : String?
    var mMatchWholeWord : Bool?
    var mMatchAccents : Bool?
    var mScripture: Scripture?
    var mSearchResults = [AISSearchResultIOS]()
    var mStopSearch = false
    var mClosing = false
    var mBook: ALSBook?
    var mRowsAdded: Int = 0
    var mScriptureController: ScriptureViewController?
    private var mSelectedIndex: NSIndexPath?
    let config = Scripture.sharedInstance.getConfig()
    
    /*        var results = searchHandler.searchForStringWithNSString(searchBar!.text, withBoolean: false , withBoolean: false)
    for result in results {
    
    }*/
    
    @IBOutlet var searchTableView: UITableView!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mCloseButton: UIBarButtonItem!
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        mStopSearch = true
        mClosing = true
        self.activityIndicator.stopAnimating()
        self.activityIndicator.hidden = true
        NSURLCache.sharedURLCache().removeAllCachedResponses()
        NSURLCache.sharedURLCache().diskCapacity = 0
        NSURLCache.sharedURLCache().memoryCapacity = 0
        // presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTableView.rowHeight = UITableViewAutomaticDimension
        searchTableView.estimatedRowHeight = 135
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        navBar.title = ALSFactoryCommon_getStringWithNSString_(ALSScriptureStringId_SEARCH_BUTTON_)
        activityIndicator.startAnimating()
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
//        mScripture!.clearBookArray()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.search()
            dispatch_async(dispatch_get_main_queue()) {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidden = true
            }
        }
        tableView.backgroundColor = UIColorFromRGB(config.getViewerBackgroundColor())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        mStopSearch = true
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return mRowsAdded
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.SearchCellReuseIdentifier, forIndexPath: indexPath) as! SearchTableViewCell

        // Configure the cell...
        var result = mSearchResults[indexPath.row]
        if ((indexPath.row == 0) && (result.numberOfMatchesInReference() == 0)) {
            var emptyString = NSMutableAttributedString(string: "")
            cell.reference = mScripture!.getString(ALSScriptureStringId_SEARCH_NO_MATCHES_FOUND_)
            cell.html = emptyString
            return cell
        }
        cell.reference = searchHandler.getReferenceTitleWithALSReference(result.getReference())
        var context = result.getContext()
        var nsContext = context as NSString
        let font = UIFont.systemFontOfSize(17.0)
        let boldFont = UIFont.boldSystemFontOfSize(17.0)
        var attributedString = NSMutableAttributedString(string: result.getContext())
        attributedString.addAttribute(NSFontAttributeName, value: font, range: NSMakeRange(0, nsContext.length))
        for (var i = 0; i < Int(result.numberOfMatchesInReference()); i++) {
            var match = result.getMatchWithInt(Int32(i))
            var textRange = NSRange(location: Int(match.getStartIndex()), length: Int(match.getEndIndex() - match.getStartIndex()))
            attributedString.addAttribute(NSUnderlineStyleAttributeName , value:NSUnderlineStyle.StyleSingle.rawValue, range: textRange)
            attributedString.addAttribute(NSFontAttributeName, value: boldFont, range: textRange)
        }
        let fgColor = UIColorFromRGB(config.getStylePropertyColorValueWithNSString(ALSStyleName_SEARCH_INFO_PANEL_, withNSString: ALCPropertyName_COLOR_))
        attributedString.addAttribute(NSForegroundColorAttributeName, value: fgColor, range: NSMakeRange(0, nsContext.length))
        cell.html = attributedString
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        mStopSearch = true
        mSelectedIndex = indexPath
        var selectedResult = mSearchResults[mSelectedIndex!.row]
        if ((mSelectedIndex!.row == 0) && ( selectedResult.numberOfMatchesInReference() == 0 )) {
            // User selected "No results found
            return
        }
        mScriptureController!.mVerseNumber = String(selectedResult.getReference().getFromVerse())
        mScriptureController!.bookNumber = mScripture!.findBookFromResult(selectedResult)!.mIndex!
        mScriptureController!.chapterNumber = Int(selectedResult.getReference().getChapterNumber())
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC) / 4))
//        dispatch_after(delayTime, dispatch_get_main_queue()) {
//            view.window?.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
//        }
        performSegueWithIdentifier(Constants.SelectSearchResult, sender: self)
//        self.performSegueWithIdentifier(Constants.SearchGoToVerseSeque, sender: self)
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation
/*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if let svc = segue.destinationViewController.contentViewController as? ScriptureViewController {
            if let identifier = segue.identifier {
                switch identifier {
                case Constants.SearchGoToVerseSeque :
                    if let nc = segue.destinationViewController as? UINavigationController {
                        nc.setToolbarHidden(false, animated: false)
                        nc.setNavigationBarHidden(true, animated: false)
                    }
                    var selectedResult = mSearchResults[mSelectedIndex!.row]
                    svc.scripture = mScripture
                    svc.mVerseNumber = String(selectedResult.getReference().getFromVerse())
                    svc.bookNumber = mScripture!.findBookFromResult(selectedResult)!.mIndex!
                    svc.chapterNumber = Int(selectedResult.getReference().getChapterNumber())
                                       
                default: break
                }
            }
        }
    }

*/
    func search() {
        AISSearchHandler_initWithALSAppLibrary_withALSDisplayWriter_withAISScriptureFactoryIOS_(searchHandler, mScripture!.getLibrary(), mScripture!.getDisplayWriter(), mScripture!.getFactory())
        searchHandler.initSearchWithNSString(mSearchString, withBoolean: mMatchWholeWord!, withBoolean: mMatchAccents!)
        var books = mScripture!.getLibrary().getMainBookCollection().getBooks()
        var resultCount = 0
        for (var i = 0; i < Int(books.size()) && !mStopSearch; i++) {
            autoreleasepool {
                var indexPaths = [NSIndexPath]()
                var object: AnyObject! = books.getWithInt(CInt(i))
                mBook = object as? ALSBook
                var group = mBook?.getGroup()
                if (mScripture!.searchGroup.isEmpty || (group == mScripture!.searchGroup)) {
                    let bookId = mBook!.getBookId();
                    searchHandler.loadBookForSearchWithALSBook(mBook)
                    for (var c = 0; c < Int(mBook!.getChapters().size()) && !mStopSearch; c++) {
                        var chapter = searchHandler.initChapterWithALSBook(mBook, withInt: CInt(c))
                        var elements = chapter.getElements()
                        for (var e = 0; e < Int(elements.size()) && !mStopSearch; e++) {
                            if (e == 75) {
                                var a = mSearchResults.count
                            }
                            var element = elements.getWithInt(CInt(e)) as! ALSElement
                            var searchResult = searchHandler.searchOneElementWithNSString(bookId, withALSChapter: chapter, withALSElement: element)
                            if (searchResult != nil) {
                                resultCount++
                                if (resultCount > Constants.MaxResults) {
                                    mStopSearch = true
                                }
//                                throttleSearchOutput(resultCount)
                                var indexPath = NSIndexPath(forRow: mSearchResults.count, inSection: 0)
                                indexPaths.append(indexPath)
                                self.mSearchResults.append(searchResult)
                            }
                        }
                    }
                }
                if mBook?.getBookId() == "REV" {
                    var a = self.mSearchResults.count + 1
                }
                searchHandler.unloadBookWithALSBook(mBook)
                if (indexPaths.count > 0) {
                    addRowToView(indexPaths, rowNumber: self.mSearchResults.count)
                }
            }
        }
        if (resultCount == 0) {
            var searchResult = AISSearchResultIOS()
            self.mSearchResults.append(searchResult)
            var indexPath = NSIndexPath(forRow: 0, inSection: 0)
            addRowToView([indexPath], rowNumber: self.mSearchResults.count)
         }
        mStopSearch = false
    }

    func addRowToView(indexPaths: [NSIndexPath], rowNumber: Int) {
        dispatch_async(dispatch_get_main_queue()) {
            if (!self.mClosing) {
                self.mRowsAdded = rowNumber

                self.tableView?.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Left)
            }
        }
    }
}
