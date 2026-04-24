//
//  LocationSearch.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 6/22/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import Foundation

public class LocationSearch
{
	func searchType(searchText : String) -> String
    {
        
        let searchArr = searchText.components(separatedBy: ",")
        let arryCount = searchArr.count;
        switch(arryCount)
        {
        case 1 :
            
            if(Int(searchArr[0].trimmingCharacters(in: .whitespaces)) != nil)
            {
             return  "zipCode"
            }
        case 2 :
            if(searchArr[1].trimmingCharacters(in: .whitespaces) == "USA")
            {
                return "state"
            }
        case 3 :
            let cityName : String = searchArr[1].trimmingCharacters(in: .whitespaces)
            let subArr = cityName.components(separatedBy: " ")
            if(subArr.count > 1 && Int(subArr[1]) != nil)
            {
                return "zipCode"
            }
            else
            {
                return "city"
            }
        default :
            return  "invalid"
        }
		return "invalid"
    }
	
	func formatCitySearch(searchText: String, stateShortName:String) -> String
	{
		let searchArr = searchText.components(separatedBy: ",")
		let citySearch = searchArr[0] + ", " + stateShortName.trimmingCharacters(in: .whitespaces) + ", USA"
		return citySearch
	}
	
	func formaatStateSearch(searchText: String) -> String
	{
		let searchArr = searchText.components(separatedBy: ",")
		let stateSearch = searchArr[0].trimmingCharacters(in: .whitespaces)
		return stateSearch
	}
	
	func formatZipSearch(searchText:String, stateShortName:String) -> String
	{
		let searchArr = searchText.components(separatedBy: ",")
		let arryCount = searchArr.count;
		if arryCount == 1
		{
			let zipSearch = searchArr[0].trimmingCharacters(in: .whitespaces)
			return zipSearch
		}
		let cityName : String = searchArr[1].trimmingCharacters(in: .whitespaces)
		let subArr = cityName.components(separatedBy: " ")
		let zipSearch = subArr[1].trimmingCharacters(in: .whitespaces)
		return zipSearch
	}
}
