//
//  HomeView.swift
//  SwiftHub
//
//  Created by Nayebaziz, Sahand on 5/15/16.
//  Copyright © 2016 Sahand Nayebaziz. All rights reserved.
//

import UIKit
import StateView

enum HomeViewKey: StateKey {
    case
    Filter,
    DidReceiveFilter,
    Repositories
}

class HomeView: StateView, FilteredDisplayDelegate, UITableViewDelegate {
    
    override func getInitialState() -> [String : Any?] {
        return [
            "repositories": Array<Repository>(),
            "filter": nil
        ]
    }
    
    override func viewDidInitialize() {
        SHGitHub.go.getRepositories(false, atPage: 0, filter: state["filter"] as? SHGithubCreatedFilter) { repos in
            self.state["repositories"] = repos
        }
    }
    
    override func render() {
        parentViewController.automaticallyAdjustsScrollViewInsets = false
        
        let repoTableView = place(RepoTableView.self, key: "table") { make in
            make.width.equalTo(self).offset(-24)
            make.centerX.equalTo(self)
            make.top.equalTo(self.parentViewController.snp_topLayoutGuideBottom)
            make.bottom.equalTo(self).offset(-72)
        }
        repoTableView.prop(forKey: HomeViewKey.Repositories, isLinkedToKeyInState: "repositories")
        
        let controlPanel = place(ControlPanelView.self, key: "controlPanel") { make in
            make.centerX.equalTo(self.snp_centerX)
            make.width.equalTo(self).offset(-24)
            make.height.equalTo(45)
            make.bottom.equalTo(self).offset(-13)
        }
        controlPanel.prop(forKey: HomeViewKey.Filter, isLinkedToKeyInState: "filter")
        controlPanel.prop(forKey: HomeViewKey.DidReceiveFilter) { values in
            self.didReceiveFilter(values["filter"] as? SHGithubCreatedFilter)
        }
    }
    
    func didReceiveFilter(filter: SHGithubCreatedFilter?) {
        SHGitHub.go.getRepositories(false, atPage: 0, filter: filter) { repos in
            self.state["filter"] = filter
            self.state["repositories"] = repos
        }
    }
}