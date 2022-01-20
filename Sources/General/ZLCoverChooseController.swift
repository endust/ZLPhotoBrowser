//
//  ZLCoverChooseController.swift
//  mama
//
//  Created by 蒋龙建 on 2020/9/16.
//  Copyright © 2020 DXY.COM. All rights reserved.
//

import UIKit

/// 发布图片 - 更换封面
class ZLCoverChooseController: ZLPhotoPreviewController {
    var chooseCoverBlock: ( (Int) -> Void)?
    var topView: UIView!
    var topBackBtn: UIButton!
    var topTitleLabel: UILabel!
    var topDoneBtn: UIButton!
    
    var bottomPhotoListView: ZLCoverPreviewSelectedView!
    
    var firstConfigTopBottomFrame = false
    override func setupUI() {
        self.view.backgroundColor = .black
        // collection view
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.collectionView.backgroundColor = .clear
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.isPagingEnabled = true
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.contentInsetAdjustmentBehavior = .never
        self.view.addSubview(self.collectionView)
        
        ZLPhotoPreviewCell.zl_register(self.collectionView)
        ZLGifPreviewCell.zl_register(self.collectionView)
        ZLLivePhotoPreviewCell.zl_register(self.collectionView)
        ZLVideoPreviewCell.zl_register(self.collectionView)
        
        setupTopView()
        addBottomPhotoListView()
    }
    
    // 禁用交互手势
    override func addPopInteractiveTransition() {}
    
    override func resetSubViewStatus() {}
    override func reloadCurrentCell() {}
    
    override func viewDidLayoutSubviews() {
        if firstConfigTopBottomFrame { return }
        firstConfigTopBottomFrame = true
        
        var insets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        if #available(iOS 11.0, *) {
            insets = self.view.safeAreaInsets
        }
        
        self.collectionView.frame = CGRect(x: -ZLPhotoPreviewController.colItemSpacing / 2, y: 0, width: self.view.frame.width + ZLPhotoPreviewController.colItemSpacing, height: self.view.frame.height)
        self.collectionView.setContentOffset(CGPoint(x: (self.view.frame.width + ZLPhotoPreviewController.colItemSpacing) * CGFloat(self.indexBeforOrientationChanged), y: 0), animated: false)
        if self.currentIndex > 0 {
            self.collectionView.contentOffset = CGPoint(x: (self.view.bounds.width + ZLPhotoPreviewController.colItemSpacing) * CGFloat(self.currentIndex), y: 0)
        }
        
        let navH = insets.top + 44
        topView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: navH)
    }
    
    @objc func didClickTopBackBtn() {
        let vc = self.navigationController?.popViewController(animated: true)
        if vc == nil {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func didClickTopDoneBtn() {
        if let chooseCoverBlock = chooseCoverBlock {
            chooseCoverBlock(currentIndex)
        }
        
        let vc = self.navigationController?.popViewController(animated: true)
        if vc == nil {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == self.collectionView else {
            return
        }
        NotificationCenter.default.post(name: ZLPhotoPreviewController.previewVCScrollNotification, object: nil)
        let offset = scrollView.contentOffset
        var page = Int(round(offset.x / (self.view.bounds.width + ZLPhotoPreviewController.colItemSpacing)))
        page = max(0, min(page, self.arrDataSources.count-1))
        if page == self.currentIndex {
            return
        }
        self.currentIndex = page
        bottomPhotoListView.currentShowModelChanged(model: self.arrDataSources[self.currentIndex])
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = self.arrDataSources[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLPhotoPreviewCell.zl_identifier(), for: indexPath) as! ZLPhotoPreviewCell

        cell.model = model
        
        return cell
    }
}

extension ZLCoverChooseController {
    func setupTopView() {
        topView = UIView()
        topView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.addSubview(topView)
        
        topBackBtn = UIButton(type: .custom)
        topBackBtn.translatesAutoresizingMaskIntoConstraints = false
        topBackBtn.setImage(getImage("zl_navBack"), for: .normal)
        topBackBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        topBackBtn.addTarget(self, action: #selector(didClickTopBackBtn), for: .touchUpInside)
        topView.addSubview(topBackBtn)
        if #available(iOS 11.0, *) {
            topBackBtn.topAnchor.constraint(equalTo: topView.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            topBackBtn.topAnchor.constraint(equalTo: topView.topAnchor).isActive = true
        }
        topBackBtn.bottomAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
        topBackBtn.leadingAnchor.constraint(equalTo: topView.leadingAnchor).isActive = true
        topBackBtn.widthAnchor.constraint(equalToConstant: 44).isActive = true
        
        topTitleLabel = UILabel()
        topTitleLabel.text = "选择封面"
        topTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        topTitleLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        topTitleLabel.textColor = .white
        topTitleLabel.textAlignment = .center
        topView.addSubview(topTitleLabel)
        topTitleLabel.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -15).isActive = true
        topTitleLabel.centerXAnchor.constraint(equalTo: topView.centerXAnchor).isActive = true

        topDoneBtn = UIButton(type: .custom)
        topDoneBtn.translatesAutoresizingMaskIntoConstraints = false
        topDoneBtn.addTarget(self, action: #selector(didClickTopDoneBtn), for: .touchUpInside)
        topDoneBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        topDoneBtn.setTitleColor(.white, for: .normal)
        topDoneBtn.setTitle("确定", for: .normal)
        topDoneBtn.backgroundColor = UIColor(red: 255 / 255, green: 128 / 255, blue: 128 / 255, alpha: 1)
        topDoneBtn.layer.cornerRadius = 12
        topDoneBtn.layer.masksToBounds = true
        topView.addSubview(topDoneBtn)
        topDoneBtn.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -15).isActive = true
        topDoneBtn.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -10).isActive = true
        topDoneBtn.widthAnchor.constraint(equalToConstant: 64).isActive = true
        topDoneBtn.heightAnchor.constraint(equalToConstant: 24).isActive = true
    }
    
    func addBottomPhotoListView() {
        bottomPhotoListView = ZLCoverPreviewSelectedView(selModels: arrDataSources,
                                                               currentShowModel: self.arrDataSources[self.currentIndex])
        bottomPhotoListView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        bottomPhotoListView.selectBlock = { [weak self] (model) in
            self?.scrollToSelPreviewCell(model)
        }
        bottomPhotoListView.endSortBlock = { [weak self] (models) in
            self?.refreshCurrentCellIndex(models)
        }
        view.addSubview(bottomPhotoListView)
        bottomPhotoListView.translatesAutoresizingMaskIntoConstraints = false
        bottomPhotoListView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bottomPhotoListView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        if #available(iOS 11.0, *) {
            bottomPhotoListView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            bottomPhotoListView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
        bottomPhotoListView.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
}


class ZLCoverPreviewSelectedView: ZLPhotoPreviewSelectedView {
    
    override func setupUI() {
        super.setupUI()
        
        // 禁止长按拖动
        if #available(iOS 11.0, *) {
            self.collectionView.dragInteractionEnabled = false
            self.collectionView.isSpringLoaded = false
        } else {
            collectionView.gestureRecognizers?.removeAll()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
        cell.layer.borderColor = UIColor.white.cgColor
        
        return cell
    }
}
