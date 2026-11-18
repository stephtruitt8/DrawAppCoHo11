//
//  Drawin.swift
//  DrawAppCoHo11
//
//  Created by Stephen Truitt on 11/9/26.
//

import SwiftUI
import PencilKit

struct DrawingView: View {
    
    @State private var canvasView = PKCanvasView() //The Paper to draw on
    @State private var toolPicker = PKToolPicker() // The Toolbox
    
    
    var body: some View {
        NavigationView {
            VStack { // pass the variables from the CanvasView Binding (parent) into our child view States
                CanvasView(canvasView: $canvasView, toolPicker: $toolPicker)
                    .navigationBarTitle("DrawApp", displayMode: .inline)
                    .navigationBarItems(
                        leading: HStack{
                            Button(action: clearCanvas){
                                // SF Symbols guide: Command + shift + L
                                Label("Clear", systemImage: "trash")
                            }
                            .keyboardShortcut("k", modifiers: .command)
                        },
                        trailing: HStack (spacing: 20) {
                            Button(action: undo) {
                                Label("Undo", systemImage: "arrow.uturn.backwards")
                            }
                            .keyboardShortcut("z", modifiers: .command)
                            Button(action: redo) {
                                Label("Redo", systemImage: "arrow.uturn.forward")
                            }
                            .keyboardShortcut("y", modifiers: .command)
                        }
                    )
                    .onAppear(perform: setupToolPicker)
                
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func setupToolPicker() {
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
    }
    
    //Deletes everything by assigning a new empty drawing object view
    private func clearCanvas() {
        canvasView.drawing = PKDrawing()
    }
    
    private func undo() {
        canvasView.undoManager?.undo()
    }
    
    private func redo() {
        canvasView.undoManager?.redo()
    }
}

//Bridge between SwiftUI -> UI Kit -> User's input

struct CanvasView:  UIViewRepresentable {
    @Binding var canvasView : PKCanvasView
    @Binding var toolPicker : PKToolPicker
    
    func makeUIView(context: Context) -> PKCanvasView {
        // Allowing the user to draw with finger or pencil
        if #available(iOS 14.0, *) {
            canvasView.drawingPolicy = .anyInput
        }else{
            canvasView.allowsFingerDrawing = true
        }
        // wait to save the event of the drawing until the stroke is finished
        canvasView.delegate = context.coordinator
        return canvasView
    }
    
    // Update UIKit based on the state changes
    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
    
    // coordinator 'middle-man' to delegate the methodss
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: CanvasView
        init(_ parent: CanvasView) {
            self.parent = parent
        }
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            print("drawing is working") //  when a stroke is finished this happens
        }
    }
    
}

