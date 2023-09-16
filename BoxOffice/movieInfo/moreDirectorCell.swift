//
//  moreDirectorCell.swift
//  BoxOffice
//
//  Created by yeolife on 2023/09/14.
//

import UIKit

class moreDirectorCell: UITableViewCell {
    var director = UILabel()
    var actor = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        drawCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension moreDirectorCell {
    private func drawCell() {
        let dummyLabel1: UILabel = UILabel()
        dummyLabel1.adjustsFontForContentSizeCategory = true
        dummyLabel1.text = "감독"
        dummyLabel1.font = UIFont.preferredFont(forTextStyle: .body)
        dummyLabel1.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.director.adjustsFontForContentSizeCategory = true
        self.director.numberOfLines = 0
        self.director.font = UIFont.preferredFont(forTextStyle: .body)
        let directorStack = UIStackView(arrangedSubviews: [dummyLabel1, director])
        directorStack.translatesAutoresizingMaskIntoConstraints = false
        directorStack.axis = .horizontal
        directorStack.alignment = .leading
        directorStack.distribution = .fill
        directorStack.spacing = 8
        
        let dummyLabel2: UILabel = UILabel()
        dummyLabel2.adjustsFontForContentSizeCategory = true
        dummyLabel2.text = "출연"
        dummyLabel2.font = UIFont.preferredFont(forTextStyle: .body)
        dummyLabel2.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.actor.adjustsFontForContentSizeCategory = true
        self.actor.numberOfLines = 0
        self.actor.font = UIFont.preferredFont(forTextStyle: .body)
        let actorStack = UIStackView(arrangedSubviews: [dummyLabel2, self.actor])
        actorStack.translatesAutoresizingMaskIntoConstraints = false
        actorStack.axis = .horizontal
        actorStack.alignment = .leading
        actorStack.distribution = .fill
        actorStack.spacing = 8
        actorStack.setContentHuggingPriority(.required, for: .vertical)
        actorStack.setContentCompressionResistancePriority(.required, for: .vertical)
        
        contentView.addSubview(directorStack)
        contentView.addSubview(actorStack)
        
        NSLayoutConstraint.activate([
            directorStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            directorStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            directorStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            actorStack.topAnchor.constraint(equalTo: directorStack.bottomAnchor, constant: 8),
            actorStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            actorStack.leadingAnchor.constraint(equalTo: directorStack.leadingAnchor),
            actorStack.trailingAnchor.constraint(equalTo: directorStack.trailingAnchor)
        ])
    }
}
