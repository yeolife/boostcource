//
//  moreReplyCell.swift
//  BoxOffice
//
//  Created by yeolife on 2023/09/14.
//

import UIKit

class moreReplyCell: UITableViewCell {
    var userProfileImage = UIImageView()
    var userName = UILabel()
    
    // 셀 재사용으로 인한 더미 값을 방지하기 위해서 초기화
    override func prepareForReuse() {
        super.prepareForReuse()
        
        userFiveStars = [UIImageView(image: UIImage(named: "ic_star_large")),
                         UIImageView(image: UIImage(named: "ic_star_large")),
                         UIImageView(image: UIImage(named: "ic_star_large")),
                         UIImageView(image: UIImage(named: "ic_star_large")),
                         UIImageView(image: UIImage(named: "ic_star_large"))]
    }
    
    var userFiveStars: [UIImageView] = [UIImageView(image: UIImage(named: "ic_star_large")),
                                        UIImageView(image: UIImage(named: "ic_star_large")),
                                        UIImageView(image: UIImage(named: "ic_star_large")),
                                        UIImageView(image: UIImage(named: "ic_star_large")),
                                        UIImageView(image: UIImage(named: "ic_star_large"))]
    var userDate = UILabel()
    var userContent = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        drawCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension moreReplyCell {
    private func drawCell() {
        userProfileImage.translatesAutoresizingMaskIntoConstraints = false
        
        let starStack: UIStackView = UIStackView(arrangedSubviews: userFiveStars)
        starStack.axis = .horizontal
        starStack.alignment = .center
        starStack.distribution = .equalSpacing
        starStack.spacing = 0
        let inUpStack = UIStackView(arrangedSubviews: [userName, starStack])
        inUpStack.axis = .horizontal
        inUpStack.alignment = .leading
        inUpStack.distribution = .equalSpacing
        inUpStack.spacing = UIStackView.spacingUseSystem
        
        userDate.adjustsFontForContentSizeCategory = true
        userDate.font = UIFont.preferredFont(forTextStyle: .caption1)
        userDate.textColor = .lightGray
        userDate.text = "2018-01-12 18:21:10"
        
        userContent.numberOfLines = 0
        
        let outStack: UIStackView = UIStackView(arrangedSubviews: [inUpStack, userDate, userContent])
        outStack.translatesAutoresizingMaskIntoConstraints = false
        outStack.axis = .vertical
        outStack.alignment = .leading
        outStack.distribution = .equalSpacing
        
        contentView.addSubview(userProfileImage)
        contentView.addSubview(outStack)
        
        userFiveStars.forEach({ star in
            star.widthAnchor.constraint(equalTo: star.heightAnchor).isActive = true
            star.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.05).isActive = true
        })
        
        NSLayoutConstraint.activate([
            userProfileImage.widthAnchor.constraint(equalTo: userProfileImage.heightAnchor),
            userProfileImage.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.15),
            userProfileImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            userProfileImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            outStack.topAnchor.constraint(equalTo: userProfileImage.topAnchor),
            outStack.leadingAnchor.constraint(equalTo: userProfileImage.trailingAnchor, constant: 8),
            outStack.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20),
            outStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
}
