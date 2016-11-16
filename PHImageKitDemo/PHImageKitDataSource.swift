//
//  PHImageKItGifDataSource.swift
//  PHImageKit
//
// Copyright (c) 2016 Product Hunt (http://producthunt.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

public enum DataType {
    case gif
    case image
}

protocol PHImageKitDataSourceDelegate {
    func contentChanged()
}

class PHImageKitDataSource: NSObject {

    var content = [URL]()

    var delegate:PHImageKitDataSourceDelegate?

    func loadData(withType type: DataType) {

        switch type {
        case .gif:
            content = gifPaths().map({ URL(string: $0)! })
        case .image:
            content = imagePaths().map({ URL(string: $0)! })
        }

        delegate?.contentChanged()
    }

    fileprivate func gifPaths() -> [String] {
        return [
            "http://media1.giphy.com/media/QgcQLZa6glP2w/200w.gif",
            "http://media1.giphy.com/media/wDs4w9nojvmG4/200w.gif",
            "http://media1.giphy.com/media/evAe2zNwDqamA/200w.gif",
            "http://media1.giphy.com/media/LImE2WbJViyGI/200w.gif",
            "http://media1.giphy.com/media/zunNjgGVFOi9G/200w.gif",
            "http://media1.giphy.com/media/x5Yf7Wfhl2WxW/200w.gif",
            "http://media1.giphy.com/media/wJb1Ie0huUCyI/200w.gif",
            "http://media1.giphy.com/media/hl8EB6j2kjDWM/200w.gif",
            "http://media1.giphy.com/media/bT1bfX2D0VIJi/200w.gif",
            "http://media1.giphy.com/media/yodYHB1s9Ujrq/200w.gif",
            "http://media1.giphy.com/media/pWbSd03oTAbnO/200w.gif",
            "http://media1.giphy.com/media/oBlBIWmmuhdzW/200w.gif",
            "http://media1.giphy.com/media/N74Z9WOMdnKvK/200w.gif",
            "http://media1.giphy.com/media/JJ3k9jY2mi0ZG/200w.gif",
            "http://media1.giphy.com/media/EvPbiBl3efxzW/200w.gif",
            "http://media1.giphy.com/media/3AkIiqu7vfriw/200w.gif",
            "http://media1.giphy.com/media/ivelTBasMg67S/200w.gif",
            "http://media1.giphy.com/media/dWhp7Do60N8vC/200w.gif",
            "http://media1.giphy.com/media/11TEBf6JI6XV3q/200w.gif",
            "http://media1.giphy.com/media/7qD1odpQnVfR6/200w.gif",
            "http://media1.giphy.com/media/5XblzuJO9uKje/200w.gif",
            "http://media1.giphy.com/media/2lCx5z6e652De/200w.gif",
            "http://media1.giphy.com/media/5KN6UqeDnyF1u/200w.gif",
            "http://media1.giphy.com/media/1431E7VsLJxfqg/200w.gif",
        ]
    }

    fileprivate func imagePaths() -> [String] {
        return [
            "https://i.ytimg.com/vi/tntOCGkgt98/maxresdefault.jpg",
            "http://beforeitsnews.com/contributor/upload/486248/images/cat-funny-5.jpg",
            "https://i.ytimg.com/vi/GchUiYAmlLM/maxresdefault.jpg",
            "http://images1.fanpop.com/images/image_uploads/Funny-Cat-Pictures-cats-935656_500_375.jpg",
            "https://tctechcrunch2011.files.wordpress.com/2014/09/product-hunt.png?w=738",
            "https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcTDpp4dA2wIxcmCoqRlLLBiZCwZw11S1sHditHZ6YhRRcMmjJ5nCQ",
        ]
    }
}
