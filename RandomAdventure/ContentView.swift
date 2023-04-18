//
//  ContentView.swift
//  RandomAdventure
//
//  Created by Nick Gordon on 3/26/23.
//

import SwiftUI


struct ContentView: View {
    @StateObject var vm: TestApi = TestApi()
    var primary = "PrimaryColor"
    var secondary = "SecondaryColor"
    var accent = "DefaultColor"
    
    
    func openMaps(workSpace: Adventure) {
    
        if let latitude = workSpace.coordinates?.latitude,
           let longitude = workSpace.coordinates?.longitude {
            
            let url = URL(string: "maps://?saddr=&daddr=\(latitude),\(longitude)")
            
            if UIApplication.shared.canOpenURL(url!) {
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            }
            
        }
    }
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                Color(primary)
                    .ignoresSafeArea()
                
                VStack(alignment: .center) {
                        
                        Text("Random \nAdventure")
                            .font(.largeTitle)
                            .foregroundColor(.primary)
                            .minimumScaleFactor(0.5)
                            
                            TextField("MUST TYPE LOCATION", text: $vm.searchTerm)
                                .padding()
                                .background(Color.gray.opacity(20))
                                .cornerRadius(20)
                                .padding()
                        
                    
                       // HStack {
                            Text("select \n genre")
                                .foregroundColor(.primary)
                                .minimumScaleFactor(0.5)
                                .font(.title3)
                            
                            Rectangle()
                                .frame(height: UIScreen.main.bounds.width * 0.15)
                                .frame(width: UIScreen.main.bounds.width * 0.55)
                                .cornerRadius(20)
                                .foregroundColor(Color(secondary))
                                .overlay (
                                    
                                    Picker(selection: $vm.firstAdventure, label: Text("Select first adventure")) {
                                        ForEach(TestApi.AdventureEnum.allCases, id: \.self) { mood in
                                            Text(mood.rawValue)
                                                .foregroundColor(Color(accent))
                                                .tag(Color.red)
                                            
                                        }
                                        
                                    }
                                        .pickerStyle(.wheel)
                                     
                                    
                                )
                      //  }
                        //.padding(.trailing, 45)
                        
                       
                    
                        Button {
                                 
                            Task {
                                await vm.generateRandomAdventureList()
                            }
                        
                          
                        } label: {
                            Rectangle()
                                .frame(height: UIScreen.main.bounds.width * 0.23)
                                .frame(width: UIScreen.main.bounds.width * 0.53)
                                .foregroundColor(Color(secondary))
                            .cornerRadius(20)
                            .padding()
                            .overlay (
                            Text("Create \n Adventure")
                                .font(.caption2)
                                .foregroundColor(Color(accent))
                              //  .minimumScaleFactor(0.6)
                                .bold()
                            )
                                
                        }
                        ScrollView {
                  
                   
                        if vm.isLoading == true {
                            ProgressView("Generating \n Adventure")
                                .foregroundColor(.black)
                                .font(.largeTitle)
                                .bold()
                        }
                        
                      
                            ForEach(vm.resultAdventures) { workSpace in
                                
                                Rectangle()
                                    .foregroundColor(Color(secondary))
                                    .frame(height: UIScreen.main.bounds.width * 0.60)
                                    .frame(width:350)
                                    .cornerRadius(20)
                                    .shadow(radius: 10)
                                    .padding()
                                    .overlay(
                                        
                                        VStack(alignment: .center) {
                                            
                           
                                            AsyncImage(url: URL(string: workSpace.imageURL ?? "https://i.ibb.co/RCJjjDm/Routerplaceholderimage.jpg")) { photo in
                                                photo.image?
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(height: UIScreen.main.bounds.width * 0.35)
                                                    .frame(width: UIScreen.main.bounds.width * 0.75)
                                                    .cornerRadius(10)
                                                
                                            }
                                            HStack {
                                                
                                                VStack(alignment: .leading) {
                                                    Text(workSpace.name)
                                                    //.font(.caption)
                                                        .font(.caption.width(.compressed))
                                                        .minimumScaleFactor(0.5)
                                                        .bold()
                                                        .padding(.leading)
                                                        .foregroundColor(Color(accent))
                                                    
                                                    
                                                    Text(workSpace.location?.address1 ?? "no location")
                                                    //.font(.caption)
                                                        .font(.caption.width(.compressed))
                                                        .minimumScaleFactor(0.5)
                                                        .bold()
                                                        .padding(.leading)
                                                        .foregroundColor(Color(accent))
                                                    
                                                    HStack {
                                                        
                                                        Text(workSpace.location?.city ?? "no location")
                                                        // .font(.caption)
                                                            .font(.caption.width(.compressed))
                                                            .minimumScaleFactor(0.5)
                                                            .bold()
                                                            .padding(.leading)
                                                            .foregroundColor(Color(accent))
                                                        
                                                        Text(workSpace.location?.state ?? "no location")
                                                        
                                                            .font(.caption.width(.compressed))
                                                            .minimumScaleFactor(0.5)
                                                            .bold()
                                                            .padding(.leading, 10)
                                                            .foregroundColor(Color(accent))
                                                        
                                                        
                                                    }
                                                    
                                                }
                                                
                                                
                                                Spacer()
                                                
                                                Button {
                                                    openMaps(workSpace: workSpace)
                                                } label: {
                                                    Image(systemName: "car.circle.fill")
                                                        .foregroundColor(Color(accent))
                                                        .font(.largeTitle)
                                                }
                                                .buttonStyle(.borderless)
                                                .padding(.trailing, 15)
                                            }
                                        }.padding()
                                        
                                    ).padding(.top, 4)
                                
                            }
                        }
                
                        Spacer()
                    }
                   
                
                }
                
            }
        }
    }



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView( vm: TestApi())
    }
}









