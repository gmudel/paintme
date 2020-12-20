//
//  paintingTableVC.swift
//  paintme
//
//  Created by Megan Worrel on 12/14/20.
//

import UIKit
import SwiftyJSON

class paintingTableVC: UITableViewController, UISearchBarDelegate, ArtistReturnDelegate {
    
    var paintings = [UIImage]()
    var image: UIImage!
    var searchArtist = ""
    var offset = 0
    var refresher = UIRefreshControl()
    @IBOutlet weak var searchbar: UISearchBar!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchbar.delegate = self
        
        refresher.attributedTitle = NSAttributedString(string: "Pulling Random Paintings")
        refresher.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.tableView.addSubview(refresher)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        getPaintings(artist: "")
        //self.tableView.rowHeight = UITableView.automaticDimension
        //self.tableView.estimatedRowHeight = 1000
    }
    
    
    @objc func refresh(_ sender: Any) {
        getPaintings(artist: "")
    }
    
    func didReturnArtist(_ artist: String) {
        getPaintings(artist: artist)
    }
    
    func getPaintings(artist: String) {
        var url: URL
        if !artist.isEmpty {
            self.searchArtist = artist
            self.offset = 0

            let modifiedArtist = artist.lowercased().filter {!$0.isWhitespace}
            url = URL(string: "http://localhost:8000/paintings/\(modifiedArtist)/\(offset)")!
        } else{
            url = URL(string: "http://localhost:8000/paintings/")!
        }

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            DispatchQueue.main.async{
                guard let data = data, let response = response as? HTTPURLResponse else { return }
                guard (200 ... 299) ~= response.statusCode else {
                    print("statusCode should be 2xx, but is \(response.statusCode)")
                    print("response = \(response)")
                    let alert = UIAlertController(title: "Error", message: "Error loading paintings", preferredStyle: .alert)

                    alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))

                    self.present(alert, animated: true)
                    return
                }
                do {
                    print(response)
                    let json = try JSON(data: data, options: .allowFragments)
                    let paintings_str = json["imgs"].arrayObject as? [String]
                    self.paintings = []
                    if let paintings_data = paintings_str {
                        for painting in paintings_data {
                            let imageData = Data(base64Encoded: painting, options: .ignoreUnknownCharacters)!
                            let image_temp = UIImage(data: imageData)
                            if image_temp != nil {
                                self.paintings.append(image_temp!)
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                catch {
                    print(error)
                }
                self.refresher.endRefreshing()
            }
        }
        task.resume()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.paintings.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "paintingCell", for: indexPath) as? paintingCell

        // Configure the cell...

        cell!.painting.image = self.paintings[indexPath.row]
        cell?.painting.frame.size.height = self.paintings[indexPath.row].size.height

        return cell!
    }

    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let artistVC = storyboard!.instantiateViewController(withIdentifier: "artistTableVC") as! artistTableVC
        artistVC.inputText = self.searchbar.text ?? ""
        artistVC.artistDelegate = self
        self.present(artistVC, animated: false, completion: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if self.searchbar.text != "" {
            let artistVC = storyboard!.instantiateViewController(withIdentifier: "artistTableVC") as! artistTableVC
            artistVC.inputText = self.searchbar.text ?? ""
            artistVC.artistDelegate = self
            self.navigationController?.pushViewController(artistVC, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let waitingVC = storyboard!.instantiateViewController(withIdentifier: "waitingVC") as! waitingVC
        waitingVC.inputImage = self.image
        waitingVC.styleImage = self.paintings[indexPath.row]
        self.navigationController?.pushViewController(waitingVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        print(paintings[indexPath.row].size.height)
        return paintings[indexPath.row].size.height
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
