//
//  moreContentCell.swift
//  BoxOffice
//
//  Created by yeolife on 2023/09/14.
//

import UIKit

class moreContentCell: UITableViewCell {
    var content = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        drawCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension moreContentCell {
    private func drawCell() {
        content.adjustsFontForContentSizeCategory = true
        content.translatesAutoresizingMaskIntoConstraints = false
        content.setContentHuggingPriority(.required, for: .vertical)
        content.numberOfLines = 0
        content.font = UIFont.preferredFont(forTextStyle: .body)
        content.text = """
        여러줄
        더미
        테스트
        입니다.
        """
        
        contentView.addSubview(content)
        
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            content.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            content.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            content.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
}
