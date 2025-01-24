//
//  ContentView.swift
//  PropertyTest
//
//  Created by KimJunsoo on 1/20/25.
//

import SwiftUI

struct ContentView: View {
    let viewNames = [
        "@State",
        "@Binding",
        "@ObservedObject",
        "@EnvironmentObject",
        "@Environment",
        "@StateObject",
        "@AppStorage",
        "@SceneStorage",
        "@FetchRequest",
        "@Namespace"
    ]
    
    // 각 View의 이름 배열
    let views: [AnyView] = [
        AnyView(View1()),
        AnyView(View2()),
        AnyView(View3()),
        AnyView(View4()),
        AnyView(View5()),
        AnyView(View6()),
        AnyView(View7()),
        AnyView(View8()),
        AnyView(View9()),
        AnyView(View10())
    ]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(0..<views.count, id: \.self) { index in
                    NavigationLink(destination: views[index]) {
                        Text(viewNames[index])
                    }
                }
            }
        }
    }
}

// 개별 View 정의
struct View1: View {
    var body: some View {
        Text("This is View 1")
            .font(.largeTitle)
            .padding()
    }
}

struct View2: View {
    var body: some View {
        Text("This is View 2")
            .font(.largeTitle)
            .padding()
    }
}

struct View3: View {
    var body: some View {
        Text("This is View 3")
            .font(.largeTitle)
            .padding()
    }
}

struct View4: View {
    var body: some View {
        Text("This is View 4")
            .font(.largeTitle)
            .padding()
    }
}

struct View5: View {
    var body: some View {
        Text("This is View 5")
            .font(.largeTitle)
            .padding()
    }
}

struct View6: View {
    var body: some View {
        Text("This is View 6")
            .font(.largeTitle)
            .padding()
    }
}

struct View7: View {
    var body: some View {
        Text("This is View 7")
            .font(.largeTitle)
            .padding()
    }
}

struct View8: View {
    var body: some View {
        Text("This is View 8")
            .font(.largeTitle)
            .padding()
    }
}

struct View9: View {
    var body: some View {
        Text("This is View 9")
            .font(.largeTitle)
            .padding()
    }
}

struct View10: View {
    var body: some View {
        Text("This is View 9")
            .font(.largeTitle)
            .padding()
    }
}

#Preview {
    ContentView()
}
