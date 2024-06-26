<a href="https://exyte.com/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/exyte/media/master/common/header-dark.png"><img src="https://raw.githubusercontent.com/exyte/media/master/common/header-light.png"></picture></a>

<a href="https://exyte.com/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/exyte/media/master/common/our-site-dark.png" width="80" height="16"><img src="https://raw.githubusercontent.com/exyte/media/master/common/our-site-light.png" width="80" height="16"></picture></a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="https://twitter.com/exyteHQ"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/exyte/media/master/common/twitter-dark.png" width="74" height="16"><img src="https://raw.githubusercontent.com/exyte/media/master/common/twitter-light.png" width="74" height="16">
</picture></a> <a href="https://exyte.com/contacts"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/exyte/media/master/common/get-in-touch-dark.png" width="128" height="24" align="right"><img src="https://raw.githubusercontent.com/exyte/media/master/common/get-in-touch-light.png" width="128" height="24" align="right"></picture></a>

<p><h1 align="left">Open AI Assistants</h1></p>

<p><h4>OpenAIAssistants is a wrapper lib for Open AI API bot interactions</h4></p>

![](https://img.shields.io/github/v/tag/exyte/OpenAIAssistants?label=Version)
[![SPM Compatible](https://img.shields.io/badge/SwiftPM-Compatible-brightgreen.svg)](https://swiftpackageindex.com/exyte/OpenAIAssistants)
[![Cocoapods Compatible](https://img.shields.io/badge/cocoapods-Compatible-brightgreen.svg)](https://cocoapods.org/pods/OpenAIAssistants)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License: MIT](https://img.shields.io/badge/License-MIT-black.svg)](https://opensource.org/licenses/MIT)

# Usage
You'll need to create a `thread`, a `message` and a `run`.  A `thread` stores your messaging history with the bot. A `run` is a task you create to ask a specific bot to process the last message in a certain `thread`.
The basic loop goes like this: user writes some input, you send this input to OpenAI's `thread` as a `message`, then create a `run` instance to process this input, check its status until it's done, fetch the response. Here is rough approximation of code:

1. Get you apiKey and assistID, you'll need to create an account
2. Create a client and a thread, store the threadID
```swift
client = OpenAI(apiKey: apiKey)

let createThreadPayload = CreateThreadPayload(
    messages: [],
    metadata: [:]
)
client.createThread(from: createThreadPayload) <...>
```
3. Prepare the `message` to send to your `thread`
```swift
let createMessagePayload = CreateMessagePayload(role: .user, content: messageText)
client.createMessage(in: threadID, payload: createMessagePayload) <...>
```
4. Create the `run`
```swift
let runPayload = CreateRunPayload(assistantId: assistID)
client.createRun(in: threadID, payload: runPayload) <...>
```
5. Retreive the `run`'s status until it's done
```swift
func checkRunStatus() {
	client.retrieveRun(id: runID, from: threadID)
	.sink { result in
	    <...>
	} receiveValue: { [weak self] run in
	    guard let self else { return }

	    if run.status != .completed {
	        usleep(300)
	        checkRunStatus()
	    } else {
	        fetchResponse()
	    }
	}
	.store(in: &subscriptions)
}
```
6. Retrive the AI's response (lastMessageID is the id of the `message` from #3)
```swift
let listPayload = ListPayload(limit: 1, after: lastMessageID)
client.listMessages(from: threadID, payload: listPayload) <...>
```

## Examples

To try the OpenAIAssistants examples:
- Clone the repo `https://github.com/exyte/openai-assistants-api`
- Open OpenAIAssistantsExample/OpenAIAssistantsExample.xcodeproj
- Try it!

## Installation

### [Swift Package Manager](https://swift.org/package-manager/)

```swift
dependencies: [
    .package(url: "https://github.com/exyte/openai-assistants-api")
]
```

### [CocoaPods](http://cocoapods.org)

To install `OpenAIAssistants`, simply add the following line to your Podfile:

```ruby
pod 'OpenAIAssistants'
```

### [Carthage](http://github.com/Carthage/Carthage)

To integrate `OpenAIAssistants` into your Xcode project using Carthage, specify it in your `Cartfile`

```ogdl
github "exyte/openai-assistants-api"
```

## Requirements

* iOS 16+, tvOS 16+, macOS 13+, watchOS 8+
* Xcode 15+ 

## Our other open source SwiftUI libraries
[PopupView](https://github.com/exyte/PopupView) - Toasts and popups library    
[Grid](https://github.com/exyte/Grid) - The most powerful Grid container    
[ScalingHeaderScrollView](https://github.com/exyte/ScalingHeaderScrollView) - A scroll view with a sticky header which shrinks as you scroll    
[AnimatedTabBar](https://github.com/exyte/AnimatedTabBar) - A tabbar with a number of preset animations   
[MediaPicker](https://github.com/exyte/mediapicker) - Customizable media picker     
[Chat](https://github.com/exyte/chat) - Chat UI framework with fully customizable message cells, input view, and a built-in media picker  
[AnimatedGradient](https://github.com/exyte/AnimatedGradient) - Animated linear gradient     
[ConcentricOnboarding](https://github.com/exyte/ConcentricOnboarding) - Animated onboarding flow    
[FloatingButton](https://github.com/exyte/FloatingButton) - Floating button menu    
[ActivityIndicatorView](https://github.com/exyte/ActivityIndicatorView) - A number of animated loading indicators    
[ProgressIndicatorView](https://github.com/exyte/ProgressIndicatorView) - A number of animated progress indicators    
[FlagAndCountryCode](https://github.com/exyte/FlagAndCountryCode) - Phone codes and flags for every country    
[SVGView](https://github.com/exyte/SVGView) - SVG parser    
[LiquidSwipe](https://github.com/exyte/LiquidSwipe) - Liquid navigation animation    