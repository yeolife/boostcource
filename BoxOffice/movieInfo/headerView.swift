//
//  headerView.swift
//  BoxOffice
//
//  Created by yeolife on 2023/09/15.
//

import UIKit

protocol replyHeaderDelegate: AnyObject {
    func tapWriteButton()
}

class headerComment: UITableViewHeaderFooterView {
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
                
        let breakLine: UIView = UIView()
        breakLine.translatesAutoresizingMaskIntoConstraints = false
        breakLine.backgroundColor = .lightGray
        
        let dummyLabel: UILabel = UILabel()
        dummyLabel.text = "줄거리"
        dummyLabel.adjustsFontForContentSizeCategory = true
        dummyLabel.translatesAutoresizingMaskIntoConstraints = false
        dummyLabel.font = UIFont.preferredFont(forTextStyle: .title2)

        contentView.addSubview(dummyLabel)
        contentView.addSubview(breakLine)
        
        NSLayoutConstraint.activate([
            breakLine.heightAnchor.constraint(equalToConstant: 3),
            breakLine.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -8),
            breakLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            breakLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            
            dummyLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            dummyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            dummyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        ])
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class headerDirector: UITableViewHeaderFooterView {
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
                
        let breakLine: UIView = UIView()
        breakLine.translatesAutoresizingMaskIntoConstraints = false
        breakLine.backgroundColor = .lightGray
        
        let dummyLabel: UILabel = UILabel()
        dummyLabel.text = "감독/출연"
        dummyLabel.adjustsFontForContentSizeCategory = true
        dummyLabel.translatesAutoresizingMaskIntoConstraints = false
        dummyLabel.font = UIFont.preferredFont(forTextStyle: .title2)

        contentView.addSubview(dummyLabel)
        contentView.addSubview(breakLine)
        
        NSLayoutConstraint.activate([
            breakLine.heightAnchor.constraint(equalToConstant: 3),
            breakLine.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -8),
            breakLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            breakLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            
            dummyLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            dummyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            dummyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        ])
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class headerReply: UITableViewHeaderFooterView {
    weak var delegate: replyHeaderDelegate?
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        let breakLine: UIView = UIView()
        breakLine.translatesAutoresizingMaskIntoConstraints = false
        breakLine.backgroundColor = .lightGray
        
        let dummyLabel: UILabel = UILabel()
        dummyLabel.text = "한줄평"
        dummyLabel.adjustsFontForContentSizeCategory = true
        dummyLabel.translatesAutoresizingMaskIntoConstraints = false
        dummyLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        
        let writeButton: UIButton = UIButton(type: .system)
        writeButton.isUserInteractionEnabled = true
        writeButton.translatesAutoresizingMaskIntoConstraints = false
        writeButton.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        writeButton.addTarget(self, action: #selector(touchUpWriteButton), for: .touchUpInside)
        
        contentView.addSubview(breakLine)
        contentView.addSubview(dummyLabel)
        contentView.addSubview(writeButton)
        
        NSLayoutConstraint.activate([
            breakLine.heightAnchor.constraint(equalToConstant: 3),
            breakLine.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -8),
            breakLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            breakLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            
            dummyLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            dummyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            dummyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            writeButton.topAnchor.constraint(equalTo: dummyLabel.topAnchor),
            writeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30)
        ])
    }
    
    @objc func touchUpWriteButton() {
        delegate?.tapWriteButton()
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
