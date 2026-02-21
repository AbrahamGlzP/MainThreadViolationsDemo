//
//  MainThreadView.swift
//  MainThreadViolationsDemo
//
//  Created by Abraham Gonzalez Puga on 20/02/26.
//

import SwiftUI

struct MainThreadView: View {
    
    @State private var viewModel = MainThreadViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                VStack(spacing: 10) {
                    //Buttons
                    Button("❌ Simulate violation") {
                        viewModel.triggerViolation()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .disabled(viewModel.isLoading)
                    
                    Button("✅ Run in main actor") {
                        Task { await viewModel.runSafely() }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .disabled(viewModel.isLoading)
                    
                    Button("🔄 Simulate legacy SDK") {
                        viewModel.runWithLegacySDK()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    .disabled(viewModel.isLoading)
                }
                .padding(.horizontal)
                
                if viewModel.isLoading {
                    ProgressView("Proccessing...")
                }
                
                GroupBox("Event log") {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 6) {
                            ForEach(viewModel.log, id: \.self) { entry in
                                Text(entry)
                                    .font(.system(.caption, design: .monospaced))
                                
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(4)
                    }
                    .frame(maxHeight: 300)
                }
                .padding(.horizontal)
                Spacer()
            }
            .padding(.top)
            .navigationTitle("Main Thread")
            
        }
    }
}

#Preview {
    MainThreadView()
}
