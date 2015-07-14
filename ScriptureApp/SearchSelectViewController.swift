//
//  SearchSelectViewController.swift
//  ScriptureApp
//
//  Created by David Moore on 6/30/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

import UIKit

class SearchSelectViewController: UIViewController, UISearchBarDelegate {

    var mScripture: Scripture?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var btnCaption = ALSFactoryCommon_getStringWithNSString_(ALSScriptureStringId_SEARCH_BUTTON_)
        var matchCaption = ALSFactoryCommon_getStringWithNSString_(ALSScriptureStringId_SEARCH_MATCH_WHOLE_WORDS_)
        var searchHint = ALSFactoryCommon_getStringWithNSString_(ALSScriptureStringId_SEARCH_TEXT_HINT_)
        matchLabel.text = matchCaption
        navBar.title = btnCaption
        searchBar.placeholder = searchHint
        searchBar.delegate = self
    }

    @IBAction func backButtonClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func searchBarSearchButtonClicked(searchBar: UISearchBar) {
         if searchBar.text.isEmpty {
            let alert:UIAlertController = UIAlertController(title: "Error", message: "Please enter a serch string!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            self.performSegueWithIdentifier(Constants.SearchResultsSeque, sender: self)
        }
        
    }
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var matchLabel: UILabel!
    @IBOutlet weak var matchSwitch: UISwitch!
    @IBOutlet weak var navBar: UINavigationItem!
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Constants.SearchResultsSeque:
                if let tvc = segue.destinationViewController.contentViewController as? SearchTableViewController {
                    tvc.mSearchString = searchBar!.text
                    tvc.mMatchWholeWord = matchSwitch!.on
                    tvc.mScripture = mScripture
                }
                
            default: break
            }
        }
    }

}
