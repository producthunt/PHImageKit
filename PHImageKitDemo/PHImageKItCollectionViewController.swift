//
//  PHImageKItCollectionViewController.swift
//  PHImageKit
//
// Copyright (c) 2016 Product Hunt (http://producthunt.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import PHImageKit

private let reuseIdentifier = "PHImageKitCellIdentifier"

class PHImageKItCollectionViewController: UICollectionViewController, PHImageKitDataSourceDelegate {

    @IBOutlet weak var segmentedControl: UISegmentedControl!

    fileprivate let imageDataSource = PHImageKitDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        imageDataSource.loadData(withType: DataType.gif)
        imageDataSource.delegate = self
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageDataSource.content.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PHImageKitCell
    
        cell.imageView.url = imageDataSource.content[indexPath.row]

        return cell
    }

    // MARK: Actions

    @IBAction func changeSelectedSegmentAction(_ sender: UISegmentedControl) {
        imageDataSource.loadData(withType: sender.selectedSegmentIndex == 0 ? DataType.gif : DataType.image)
    }

    @IBAction func reload(_ sender: AnyObject) {
        contentChanged()
    }

    @IBAction func clearCache(_ sender: AnyObject) {
        PHManager.sharedInstance.purgeCache(includingFileCache: true)
    }

    // MARK: PHImageKitDataSourceDelegate

    func contentChanged() {
        collectionView?.reloadData()
    }

    // MARK: Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            if let destination = segue.destination as? PHImageKitDetailsViewController, let selectedIndex = collectionView?.indexPathsForSelectedItems?.first {
                destination.url = imageDataSource.content[(selectedIndex as NSIndexPath).row]
            }
        }
    }

}
