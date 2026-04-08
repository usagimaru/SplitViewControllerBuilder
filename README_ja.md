# SplitViewControllerBuilder

[English](README.md)

macOSの`NSSplitViewController`レイアウトを構築するSwift Packageです。
サイドバー、コンテンツリスト、コンテンツ領域、インスペクタの各ペインをシンプルなAPIで定義できます。


## 要件

- macOS 11以降
- Swift 6


## インストール

Swift Package Managerで追加します:

```swift
dependencies: [
    .package(url: "https://github.com/usagimaru/SplitViewControllerBuilder.git", from: "0.1.0")
]
```

インポート:

```swift
import SplitViewControllerBuilder
```


## 使い方


### SplitViewControllerの構築

`SplitViewController`を作成し、専用メソッドでペインを追加します。各メソッドは`NSSplitViewItem`を返すため、追加のカスタマイズが可能です。

```swift
let splitViewController = SplitViewController()

splitViewController.addSidebar(sidebarVC)
splitViewController.addContentList(contentListVC)
splitViewController.addContentArea(detailVC)
splitViewController.addInspector(inspectorVC)
```

- `addSidebar(_:)` — サイドバーペインをindex 0に追加
- `addContentList(_:)` — コンテンツリストペインをサイドバーの次（サイドバーがなければindex 0）に追加
- `addContentArea(_:behavior:)` — コンテンツ領域をインスペクタの手前（またはリスト末尾）に追加。デフォルトは`.default` behavior
- `addInspector(_:)` — インスペクタペインをリスト末尾に追加

すべてのメソッドは`@discardableResult`で`NSSplitViewItem`を返すため、プロパティの追加設定をチェーンできます:

```swift
splitViewController.addContentArea(detailVC).holdingPriority = .defaultLow
```


### ペインのBehavior

各メソッドは内部で適切なbehaviorと設定を持つ`NSSplitViewItem`を生成します:

| メソッド | Behavior | 設定 |
|---------|----------|------|
| `addSidebar` | `.sidebar` | 全高レイアウト、最小幅あり |
| `addContentList` | `.contentList` | 全高レイアウト、最小幅あり |
| `addContentArea` | `.default` | 素のアイテム（返り値で個別にカスタマイズ可） |
| `addInspector` | `.inspector` | 全高レイアウト |


### サブクラスのカスタマイズ

`SplitViewController`は`NSSplitView`と`NSSplitViewItem`のクラスをオーバーライドするポイントを提供します:

```swift
class MySplitViewController: SplitViewController {
    override var splitViewClass: NSSplitView.Type {
        MySplitView.self
    }
    override var splitViewItemClass: NSSplitViewItem.Type {
        MySplitViewItem.self
    }
    override func configureSplitView() -> NSSplitView {
        let sv = super.configureSplitView()
        sv.dividerStyle = .paneSplitter
        return sv
    }
}
```


### Split View Itemへのアクセス

```swift
// 特定のbehaviorに一致する全アイテムを取得
let sidebars = splitViewController.splitViewItems(for: .sidebar)

// 特定のbehaviorに一致する最初のアイテムを取得
let inspector = splitViewController.firstSplitViewItem(for: .inspector)

// View Controllerのクラスで最初のアイテムを取得
let item = splitViewController.firstItemForViewControllerClass(MyViewController.self)

// View Controllerのクラスによる型安全なアクセス
let pane: SplitViewController.SplitItemInfo<MyViewController>? = splitViewController.firstPane()
```

`SplitItemInfo<T>`はアイテムのインデックス、`NSSplitViewItem`、型付きのView Controllerをまとめて提供します。


### 折りたたみ状態の切り替え

`NSSplitViewItem`の拡張により、アニメーション付きの折りたたみ切り替えが可能です:

```swift
// アニメーション付きで切り替え
item.toggleCollapsed(animated: true)

// 特定の状態を設定、nilを渡すとトグル
item.setCollapsed(true, animated: true)
```

どちらのメソッドもアクセシビリティの**視差効果を減らす**設定を自動的に尊重します。


## ライセンス

[LICENSE](./LICENSE)
