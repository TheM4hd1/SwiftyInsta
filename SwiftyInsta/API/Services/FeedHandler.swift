//
//  FeedHandler.swift
//  SwiftyInsta
//
//  Created by Mahdi Makhdumi on 11/23/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public protocol FeedHandlerProtocol {
    func getExploreFeeds(paginationParameter: PaginationParameters, completion: @escaping (Result<[ExploreFeedModel]>) -> ()) throws
    func getTagFeed(tagName: String, paginationParameter: PaginationParameters, completion: @escaping (Result<[TagFeedModel]>) -> ()) throws
    func getUserTimeLine(paginationParameter: PaginationParameters, completion: @escaping (Result<[TimeLineModel]>) -> ()) throws
}

class FeedHandler: FeedHandlerProtocol {
    static let shared = FeedHandler()
    
    private init() {
        
    }
    
    func getExploreFeeds(paginationParameter: PaginationParameters, completion: @escaping (Result<[ExploreFeedModel]>) -> ()) throws {
        getExploreList(from: try URLs.getExploreFeedUrl(), exploreList: [], paginationParameter: paginationParameter) { (list) in
            completion(Return.success(value: list))
        }
    }
    
    fileprivate func getExploreList(from url: URL, exploreList: [ExploreFeedModel], paginationParameter: PaginationParameters, completion: @escaping ([ExploreFeedModel]) -> ()) {
        if paginationParameter.pagesLoaded == paginationParameter.maxPagesToLoad {
            completion(exploreList)
        } else {
            var _paginationParameter = paginationParameter
            _paginationParameter.pagesLoaded += 1
            var list = exploreList
            guard let httpHelper = HandlerSettings.shared.httpHelper else {return}
            httpHelper.sendAsync(method: .get, url: url, body: [:], header: [:]) { [weak self] (data, response, error) in
                if error != nil {
                    completion(list)
                } else {
                    if response?.statusCode != 200 {
                        completion(list)
                    } else {
                        if let data = data {
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase
                            do {
                                let newItems = try decoder.decode(ExploreFeedModel.self, from: data)
                                list.append(newItems)
                                if newItems.moreAvailable! {
                                    _paginationParameter.nextId = newItems.nextMaxId!
                                    let url = try URLs.getExploreFeedUrl(maxId: _paginationParameter.nextId)
                                    self?.getExploreList(from: url, exploreList: list, paginationParameter: _paginationParameter, completion: { (result) in
                                        completion(result)
                                    })
                                } else {
                                    completion(list)
                                }
                            } catch {
                                completion(list)
                            }
                        } else {
                            completion(list)
                        }
                    }
                }
            }
        }
    }
    
    func getTagFeed(tagName: String, paginationParameter: PaginationParameters, completion: @escaping (Result<[TagFeedModel]>) -> ()) throws {
        getTagList(for: try URLs.getTagFeed(for: tagName), tag: tagName, list: [], paginationParameter: paginationParameter) { (value) in
            completion(Return.success(value: value))
        }
    }

    fileprivate func getTagList(for url: URL, tag: String, list: [TagFeedModel], paginationParameter: PaginationParameters, completion: @escaping ([TagFeedModel]) -> ()) {
        if paginationParameter.pagesLoaded == paginationParameter.maxPagesToLoad {
            completion(list)
        } else {
            var _paginationParameter = paginationParameter
            _paginationParameter.pagesLoaded += 1
            
            guard let httpHelper = HandlerSettings.shared.httpHelper else {return}
            httpHelper.sendAsync(method: .get, url: url, body: [:], header: [:]) { [weak self] (data, response, error) in
                if error != nil {
                    completion(list)
                } else {
                    if let data = data {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        do {
                            var tagList = list
                            let newItems = try decoder.decode(TagFeedModel.self, from: data)
                            tagList.append(newItems)
                            if newItems.moreAvailable! {
                                _paginationParameter.nextId = newItems.nextMaxId!
                                let url = try! URLs.getTagFeed(for: tag, maxId: _paginationParameter.nextId)
                                self!.getTagList(for: url, tag: tag, list: tagList, paginationParameter: _paginationParameter, completion: { (result) in
                                    completion(result)
                                })
                            } else {
                                completion(tagList)
                            }
                        } catch {
                            completion(list)
                        }
                    } else {
                        completion(list)
                    }
                }
            }
        }
    }
    
    func getUserTimeLine(paginationParameter: PaginationParameters, completion: @escaping (Result<[TimeLineModel]>) -> ()) throws {
        getTimeLineList(from: try URLs.getUserTimeLineUrl(), list: [], paginationParameter: paginationParameter) { (list) in
            completion(Return.success(value: list))        }
    }
    
    fileprivate func getTimeLineList(from url: URL, list: [TimeLineModel], paginationParameter: PaginationParameters, completion: @escaping ([TimeLineModel]) -> ()) {
        if paginationParameter.pagesLoaded == paginationParameter.maxPagesToLoad {
            completion(list)
        } else {
            var _paginationParameter = paginationParameter
            _paginationParameter.pagesLoaded += 1
            var timelineList = list
            guard let httpHelper = HandlerSettings.shared.httpHelper else {return}
            httpHelper.sendAsync(method: .post, url: url, body: [:], header: [:]) { [weak self] (data, response, error) in
                if error != nil {
                    completion(timelineList)
                } else {
                    if response?.statusCode != 200 {
                        completion(timelineList)
                    } else {
                        if let data = data {
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase
                            do {
                                let newItems = try decoder.decode(TimeLineModel.self, from: data)
                                timelineList.append(newItems)
                                if newItems.moreAvailable! {
                                    _paginationParameter.nextId = newItems.nextMaxId!
                                    let url = try URLs.getUserTimeLineUrl(maxId: _paginationParameter.nextId)
                                    self!.getTimeLineList(from: url, list: timelineList, paginationParameter: _paginationParameter, completion: { (result) in
                                        completion(result)
                                    })
                                } else {
                                    completion(timelineList)
                                }
                            } catch {
                                completion(timelineList)
                            }
                        } else {
                            completion(timelineList)
                        }
                    }
                }
            }
        }
    }
}
