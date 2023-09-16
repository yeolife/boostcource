//
//  movieInfoCell.swift
//  BoxOffice
//
//  Created by yeolife on 2023/09/12.
//

import UIKit

protocol ImageCellDelegate: AnyObject {
    func imageTapped(_ image: UIImage)
}

class moreInfoCell: UITableViewCell {
    weak var delegate: ImageCellDelegate?
    
    var moviePoster = UIImageView()
    
    var movieTitle = UILabel()
    var movieAge = UIImageView()
    var movieDate = UILabel()
    var movieGenre = UILabel()
    
    var movieReservationRate = UILabel()
    var movieGradePoint = UILabel()
    
    var movieFiveStars: [UIImageView] = [UIImageView(image: UIImage(named: "ic_star_large")),
                                         UIImageView(image: UIImage(named: "ic_star_large")),
                                         UIImageView(image: UIImage(named: "ic_star_large")),
                                         UIImageView(image: UIImage(named: "ic_star_large")),
                                         UIImageView(image: UIImage(named: "ic_star_large"))]
    
    var movieAudienceCount = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        
        selectionStyle = .none
        
        drawCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension moreInfoCell {
    private func drawCell() {
        moviePoster.contentMode = .scaleAspectFill
        moviePoster.translatesAutoresizingMaskIntoConstraints = false
        moviePoster.isUserInteractionEnabled = true
        let tapPoster = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        moviePoster.addGestureRecognizer(tapPoster)
        
        movieTitle.adjustsFontForContentSizeCategory = true
        movieTitle.font = UIFont.preferredFont(forTextStyle: .title2)
        movieTitle.text = "영화제목"
        
        movieDate.adjustsFontForContentSizeCategory = true
        movieDate.font = UIFont.preferredFont(forTextStyle: .body)
        movieDate.text = "1999-01-01 개봉"
        
        movieGenre.adjustsFontForContentSizeCategory = true
        movieGenre.font = UIFont.preferredFont(forTextStyle: .body)
        movieGenre.text = "판타지, 드라마/139분"
        
        movieReservationRate.adjustsFontForContentSizeCategory = true
        movieReservationRate.font = UIFont.preferredFont(forTextStyle: .body)
        movieReservationRate.text = "1위 35.5%"
        
        movieGradePoint.adjustsFontForContentSizeCategory = true
        movieGradePoint.font = UIFont.preferredFont(forTextStyle: .body)
        movieGradePoint.text = "7.98"
        
        movieAudienceCount.adjustsFontForContentSizeCategory = true
        movieAudienceCount.font = UIFont.preferredFont(forTextStyle: .body)
        movieAudienceCount.text = "11,676,822"
        
        // 윗줄
        let titleStack: UIStackView = UIStackView(arrangedSubviews: [movieTitle, movieAge])
        titleStack.axis = .horizontal
        titleStack.alignment = .center
        titleStack.distribution = .equalSpacing
        titleStack.spacing = UIStackView.spacingUseSystem
        
        let outUpStack: UIStackView = UIStackView(arrangedSubviews: [titleStack, movieDate, movieGenre])
        outUpStack.translatesAutoresizingMaskIntoConstraints = false
        outUpStack.axis = .vertical
        outUpStack.alignment = .leading
        outUpStack.distribution = .equalSpacing
        outUpStack.spacing = UIStackView.spacingUseSystem
        
        // 아랫줄
        let dummyLabel1 = UILabel()
        dummyLabel1.text = "예매율"
        let inDownStack1: UIStackView = UIStackView(arrangedSubviews: [dummyLabel1, movieReservationRate])
        inDownStack1.axis = .vertical
        inDownStack1.alignment = .center
        inDownStack1.distribution = .fillEqually
        inDownStack1.spacing = 0
        
        let dummyLabel2 = UILabel()
        dummyLabel2.text = "평점"
        let starStack: UIStackView = UIStackView(arrangedSubviews: movieFiveStars)
        starStack.axis = .horizontal
        starStack.alignment = .center
        starStack.distribution = .equalSpacing
        starStack.spacing = 0
        let inDownStack2: UIStackView = UIStackView(arrangedSubviews: [dummyLabel2, movieGradePoint, starStack])
        inDownStack2.axis = .vertical
        inDownStack2.alignment = .center
        inDownStack2.distribution = .fillEqually
        inDownStack2.spacing = 5
        
        let dummyLabel3 = UILabel()
        dummyLabel3.text = "누적관객수"
        let inDownStack3: UIStackView = UIStackView(arrangedSubviews: [dummyLabel3, movieAudienceCount])
        inDownStack3.axis = .vertical
        inDownStack3.alignment = .center
        inDownStack3.distribution = .fillEqually
        inDownStack3.spacing = 0
        
        let breakLine1: UIView = UIView()
        let breakLine2: UIView = UIView()
        breakLine1.backgroundColor = .lightGray
        breakLine2.backgroundColor = .lightGray
        breakLine1.translatesAutoresizingMaskIntoConstraints = false
        breakLine2.translatesAutoresizingMaskIntoConstraints = false
        breakLine1.setContentHuggingPriority(.required, for: .horizontal)
        breakLine2.setContentHuggingPriority(.required, for: .horizontal)
        breakLine1.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        breakLine2.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        breakLine1.widthAnchor.constraint(equalToConstant: 1).isActive = true
        breakLine2.widthAnchor.constraint(equalToConstant: 1).isActive = true
        
        let outDownStack: UIStackView = UIStackView(arrangedSubviews: [inDownStack1,
                                                                       breakLine1,
                                                                       inDownStack2,
                                                                       breakLine2,
                                                                       inDownStack3])
        outDownStack.translatesAutoresizingMaskIntoConstraints = false
        outDownStack.axis = .horizontal
        outDownStack.alignment = .fill
        outDownStack.distribution = .equalSpacing
        
        contentView.addSubview(moviePoster)
        contentView.addSubview(outUpStack)
        contentView.addSubview(outDownStack)
        
        movieFiveStars.forEach({ star in
            star.widthAnchor.constraint(equalTo: star.heightAnchor).isActive = true
            star.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.05).isActive = true
        })
        
        NSLayoutConstraint.activate([
            moviePoster.heightAnchor.constraint(equalTo: moviePoster.widthAnchor, multiplier: 1.5),
            moviePoster.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.3),
            moviePoster.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            moviePoster.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            
            movieAge.widthAnchor.constraint(equalTo: movieAge.heightAnchor),
            movieAge.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -50),
            
            movieDate.trailingAnchor.constraint(greaterThanOrEqualTo: contentView.trailingAnchor, constant: -5),
            movieGenre.trailingAnchor.constraint(greaterThanOrEqualTo: contentView.trailingAnchor, constant: -5),
            
            outUpStack.centerYAnchor.constraint(equalTo: moviePoster.centerYAnchor),
            outUpStack.leadingAnchor.constraint(equalTo: moviePoster.trailingAnchor, constant: 16),
            
            outDownStack.topAnchor.constraint(equalTo: moviePoster.bottomAnchor, constant: 8),
            outDownStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            outDownStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            outDownStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
        ])
        
    }
    
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        delegate?.imageTapped(moviePoster.image ?? UIImage())
    }
}
