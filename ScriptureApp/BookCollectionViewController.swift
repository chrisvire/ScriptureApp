//
//  BookCollectionViewController.swift
//  ScriptureApp
//
//  Created by Keith Bauson on 7/8/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

let bookReuseIdentifier = "BookButtonCell"
let bookSectionReuseIdentifier = "BookSectionHeadingCell"

class BookCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var bookIndex = 0
    var books = scripture.getBookArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.delegate = self
//        collectionView?.backgroundColor = scripture.getPopupBackgroundColor()
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return books.count
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books[section].count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        // hide if empty or section titles not shown
        if !config.hasFeatureWithNSString(ALSScriptureFeatureName_BOOK_GROUP_TITLES_) || books[section].first!.mBookGroupString!.isEmpty {
            return CGSizeZero
        } else {
            return (collectionViewLayout as! UICollectionViewFlowLayout).headerReferenceSize
        }
    }
    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        let cvfl = collectionViewLayout as! UICollectionViewFlowLayout
//        let style = scripture.getString(ALSStyleName_UI_BOOK_BUTTON_GRID_)
//        let widthString = config.getStylePropertyValueWithNSString(style, withNSString: ALCPropertyName_WIDTH_)
//        let heightString = config.getStylePropertyValueWithNSString(style, withNSString: ALCPropertyName_HEIGHT_)
//        var width = CGFloat(ALCStringUtils_getFirstDigitsAsIntWithJavaLangCharSequence_(widthString))
//        var height = CGFloat(ALCStringUtils_getFirstDigitsAsIntWithJavaLangCharSequence_(heightString))
//        if width <= 0 {
//            width = cvfl.itemSize.width
//        }
//        if height <= 0 {
//            height = cvfl.itemSize.height
//        }
//        return CGSizeMake(width, height)
//    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let flow = collectionViewLayout as! UICollectionViewFlowLayout
        if scripture.useListView() {
            let width = collectionView.bounds.size.width - flow.sectionInset.left - flow.sectionInset.right
            let height = UIButton().intrinsicContentSize().height
            return CGSizeMake(width, height)
        } else {
            return flow.itemSize
        }
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(bookReuseIdentifier, forIndexPath: indexPath) as! BookCollectionViewCell
        let book = books[indexPath.section][indexPath.item]
        
        cell.button.section = indexPath.section
        cell.button.book = indexPath.item
        cell.button.setTitle(getBookButtonTitle(book), forState: .Normal)
        if !scripture.useListView() {
            cell.button.backgroundColor = book.getBackgroundColor()
        } else {
            cell.button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        }
//        cell.button.setTitleColor(book.getColor(), forState: .Normal)
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: bookSectionReuseIdentifier, forIndexPath: indexPath) as! BookSectionCollectionReusableView
        let book = books[indexPath.section][indexPath.item]
        
        cell.label.text = book.mBookGroupString!
        
        return cell
    }

    @IBAction func selectBook(sender: BookButton) {
        let selectedSection = sender.section
        let selectedBook = sender.book
        for section in 0..<selectedSection {
            bookIndex += books[section].count
        }
        bookIndex += selectedBook
        
        performSegueWithIdentifier("unwindBook", sender: self)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func getBookButtonTitle(book: Book) -> String {
        if scripture.useListView() {
            return book.getName()
        } else {
            var title = book.getAbbrevName()
            if title.isEmpty {
                title = book.getName()
            }
            return title
        }
    }
    
}

class BookCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var button: BookButton!
}

class BookButton: UIButton {
    var section = 0
    var book = 0
}

class BookSectionCollectionReusableView: UICollectionReusableView {
    @IBOutlet weak var label: UILabel!
}