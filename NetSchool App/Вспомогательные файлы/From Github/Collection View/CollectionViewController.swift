// Copyright 2017 Brightec
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit

class CollectionViewController: UIViewController {

    let contentCellIdentifier = "ContentCellIdentifier"
    var data: TableData = TableData(countOfSections: 0, countOfRows: 0, data: [[""]])
    @IBOutlet weak var collectionView: UICollectionView!

    func load_data(data: TableData){
        self.data = data
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "ContentCollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: contentCellIdentifier)
    }

}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension CollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return data.countOfSections
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.countOfRows
    }
   
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: contentCellIdentifier, for: indexPath) as! ContentCollectionViewCell
        cell.backgroundColor = indexPath.section % 2 == 0 ? UIColor.white : UIColor(white: 242/255, alpha: 1.0)
        cell.contentLabel.text = data.data[indexPath.section][indexPath.row]
        cell.contentLabel.lineBreakMode = .byWordWrapping
        cell.contentLabel.numberOfLines = 2
        return cell
    }
}








