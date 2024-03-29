//
//  ResultTableViewControllerExtensions.swift
//  MJWeather
//
//  Created by 구민준 on 04/08/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import UIKit
import MapKit

extension ResultTableViewController {
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return searchResults.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell")!
    let searchResult = searchResults[indexPath.row]
    cell.textLabel?.text = searchResult.title
    cell.detailTextLabel?.text = searchResult.subtitle
    return cell
    
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let region = searchResults[indexPath.row].title
    let request = MKLocalSearch.Request(completion: searchResults[indexPath.row])
    request.region = MKCoordinateRegion()
    let search = MKLocalSearch(request: request)
    search.start { (response, error) in
      guard let response = response else { return }
      let latitude = response.mapItems[0].placemark.coordinate.latitude
      let longitude = response.mapItems[0].placemark.coordinate.longitude
      let storage = LocationStorage()
      let newLocation = Location(latitude: latitude, longitude: longitude, region: region)
      
      if storage.isExist(location: newLocation) {
        self.dismiss(animated: true, completion: {
          let alertViewController = UIAlertController(title: "알림", message: "이미 존재하는 지역입니다. 새로고침 하여 확인해보세요", preferredStyle: .alert)
          let alertAction = UIAlertAction(title: "확인", style: .default)
          alertViewController.addAction(alertAction)
          if let topController = UIApplication.shared.keyWindow?.rootViewController {
            topController.present(alertViewController, animated: true, completion: nil)
          }
        })
      } else {
        storage.save(location: newLocation)
        self.delegate?.addPlace(latitude: latitude, longitude: longitude, region: region)
      }
      self.dismiss(animated: true, completion: nil)
    }
  }
}

extension ResultTableViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    guard let searchBarText = searchController.searchBar.text else { return }
    searchCompleter.queryFragment = searchBarText
  }
}

extension ResultTableViewController: MKLocalSearchCompleterDelegate {
  func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
    searchResults = completer.results.filter { $0.subtitle.count == 0 }
    tableView.reloadData()
  }
}
