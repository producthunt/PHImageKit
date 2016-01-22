//
//  PHImageKItCollectionViewController.swift
//  PHImageKit
//
//  Created by Vlado on 1/22/16.
//  Copyright © 2016 ProductHunt. All rights reserved.
//

import UIKit
import PHImageKit

private let reuseIdentifier = "PHImageKitCellIdentifier"

class PHImageKItCollectionViewController: UICollectionViewController, PHImageKitDataSourceDelegate {

    @IBOutlet weak var segmentedControl: UISegmentedControl!

    private let imageDataSource = PHImageKitDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        imageDataSource.loadData(withType: DataType.GIF)
        imageDataSource.delegate = self
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageDataSource.content.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PHImageKitCell
    
        cell.imageView.url = imageDataSource.content[indexPath.row]

        return cell
    }

    // MARK: Actions

    @IBAction func changeSelectedSegmentAction(sender: UISegmentedControl) {
        imageDataSource.loadData(withType: sender.selectedSegmentIndex == 0 ? DataType.GIF : DataType.Image)
    }

    @IBAction func reload(sender: AnyObject) {
        contentChanged()
    }

    @IBAction func clearCache(sender: AnyObject) {
        PHManager.sharedInstance.purgeCache(includingFileCache: true)
    }

    // MARK: PHImageKitDataSourceDelegate

    func contentChanged() {
        collectionView?.reloadData()
    }

    // MARK: Segua

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetails" {
            if let destination = segue.destinationViewController as? PHImageKitDetailsViewController, let selectedIndex = collectionView?.indexPathsForSelectedItems()?.first {
                destination.url = imageDataSource.content[selectedIndex.row]
            }
        }
    }

}
