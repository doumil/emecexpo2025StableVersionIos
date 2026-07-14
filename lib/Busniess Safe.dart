import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:emecexpo/providers/theme_provider.dart'; // Import ThemeProvider

class BusinessScreen extends StatefulWidget {
  const BusinessScreen({Key? key}) : super(key: key);

  @override
  _BusinessScreenState createState() => _BusinessScreenState();
}

class _BusinessScreenState extends State<BusinessScreen> {
  void initState() {
    super.initState();
  }

  // Future<bool> _onWillPop() async {
  //   return (await showDialog(
  //     context: context,
  //     builder: (context) => new AlertDialog(
  //       title: new Text('Êtes-vous sûr'),
  //       content: new Text('Voulez-vous quitter une application'),
  //       actions: <Widget>[
  //         new TextButton(
  //           onPressed: () => Navigator.of(context).pop(false),
  //           child: new Text('Non'),
  //         ),
  //         new TextButton(
  //           onPressed: () => SystemNavigator.pop(),
  //           child: new Text('Oui '),
  //         ),
  //       ],
  //     ),
  //   )) ??
  //       false;
  // }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    // 💡 Access the theme provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    return
      //WillPopScope(
        //onWillPop: _onWillPop,
         FadeInDown(
          duration: Duration(milliseconds: 500),
          child: Scaffold(
            // ✅ Apply a background color to the scaffold if needed, e.g., white or black
            backgroundColor: theme.whiteColor,
            extendBodyBehindAppBar: true,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset(
                    'assets/safety/earth.gif',
                    width: width,
                    height: 250,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 5.0, right: 5.0),
                    padding: EdgeInsets.fromLTRB(4, 4, 4, 4),
                    decoration: BoxDecoration(
                      // ✅ Apply primaryColor
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(5.0),
                        right: Radius.circular(5.0),
                      ),
                    ),
                    width: double.maxFinite,
                    child: Text(
                      "Prevent COVID-19: How to Protect Yourself from the Coronavirus",
                      style: TextStyle(
                        // ✅ Apply whiteColor
                          color: theme.whiteColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(width * 0.04,
                                width * 0.04, width * 0.04, width * 0.01),
                            child: Column(children: <Widget>[
                              Text(
                                // ✅ Apply blackColor
                                "the COVID-19 pandemic has been a part of our daily lives since March 2020, but with about 151,000 new cases a day in the United States, it remains as "
                                    "important as ever to stay vigilant and know how to protect yourself from coronavirus."
                                    "According to the Centers for Disease Control and Prevention (CDC), “The best way to prevent illness is to avoid being exposed to this virus.” "
                                    "As the vaccines continue their roll out, here are the simple steps you can take to help prevent the spread of COVID-19 and protect yourself and others.",
                                style: TextStyle(color: theme.blackColor),
                              ),
                            ]),
                          ),
                        ),
                      ],
                    ),
                    width: double.infinity,
                    decoration: BoxDecoration(),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 5.0, right: 5.0),
                    padding: EdgeInsets.fromLTRB(4, 4, 4, 4),
                    decoration: BoxDecoration(
                      // ✅ Apply primaryColor
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(5.0),
                        right: Radius.circular(5.0),
                      ),
                    ),
                    width: double.maxFinite,
                    child: Text(
                      "Know how it spreads",
                      style: TextStyle(
                        // ✅ Apply whiteColor
                          color: theme.whiteColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(width * 0.04,
                                width * 0.04, width * 0.04, width * 0.01),
                            child: Column(children: <Widget>[
                              Text(
                                // ✅ Apply blackColor
                                "Scientists are still learning about COVID-19, the disease caused by the coronavirus, but according to the CDC, this highly contagious virus appears to be most commonly spread during close (within 6 feet) person-to-person contact through respiratory droplets."
                                    "“The means of transmission can be through respiratory droplets produced when a person coughs or sneezes, or by direct physical contact with an infected person, such as shaking hands,” says Dr. David Goldberg, an internist and infectious disease specialist at NewYork-Presbyterian Medical Group Westchester and an assistant professor of medicine at Columbia University Vagelos College of Physicians and Surgeons."
                                    "The CDC also notes that COVID-19 can spread by airborne transmission, although this is less common than close contact with a person. “Some infections can be spread by exposure to virus in small droplets and particles that can linger in the air for minutes to hours,” the CDC states. “These viruses may be able to infect people who are further than 6 feet away from the person who is infected or after that person has left the space. These transmissions occurred within enclosed spaces that had inadequate ventilation."
                                    "Finally, it’s possible for coronavirus to spread through contaminated surfaces, but this is also less likely. According to the CDC, “Based on data from lab studies on COVID-19 and what we know about similar respiratory diseases, it may be possible that a person can get COVID-19 by touching a surface or object that has the virus on it and then touching their own mouth, nose, or possibly their eyes, but this isn’t thought to be the main way the virus spreads.”",
                                style: TextStyle(color: theme.blackColor),
                              ),
                            ]),
                          ),
                        ),
                      ],
                    ),
                    width: double.infinity,
                    decoration: BoxDecoration(),
                  ),
                  Image.asset(
                    '',
                    width: width,
                    height: 250,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 5.0, right: 5.0),
                    padding: EdgeInsets.fromLTRB(4, 4, 4, 4),
                    decoration: BoxDecoration(
                      // ✅ Apply primaryColor
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(5.0),
                        right: Radius.circular(5.0),
                      ),
                    ),
                    width: double.maxFinite,
                    child: Text(
                      "Practice social distancing",
                      style: TextStyle(
                        // ✅ Apply whiteColor
                          color: theme.whiteColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(width * 0.04,
                                width * 0.04, width * 0.04, width * 0.01),
                            child: Column(children: <Widget>[
                              Text(
                                // ✅ Apply blackColor
                                "Since close person-to-person contact appears to be the main source of transmission, social distancing remains a key way to mitigate spread. The CDC recommends maintaining a distance of approximately 6 feet from others in public places. This distance will help you avoid direct contact with respiratory droplets produced by coughing or sneezing."
                                    "In addition, studies have found that outdoor settings with enough space to distance and good ventilation will reduce risk of exposure. “There is up to 80% less transmission of the virus happening outdoors versus indoors,” says Dr. Ashwin Vasan, an assistant attending physician in the Department of Medicine at NewYork-Presbyterian/Columbia University Irving Medical Center and an assistant professor at the Mailman School of Public Health and Columbia University Vagelos College of Physicians and Surgeons. “One study found that of 318 outbreaks that accounted for 1,245 confirmed cases in China, only one outbreak occurred outdoors. That’s significant. I recommend spending time with others outside. We’re not talking about going to a sporting event or a concert. We’re talking about going for a walk or going to the park, or even having a conversation at a safe distance with someone outside.",
                                style: TextStyle(color: theme.blackColor),
                              ),
                            ]),
                          ),
                        ),
                      ],
                    ),
                    width: double.infinity,
                    decoration: BoxDecoration(),
                  ),
                  Image.asset(
                    'assets/safety/hand.gif',
                    width: width,
                    height: 250,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 5.0, right: 5.0),
                    padding: EdgeInsets.fromLTRB(4, 4, 4, 4),
                    decoration: BoxDecoration(
                      // ✅ Apply primaryColor
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(5.0),
                        right: Radius.circular(5.0),
                      ),
                    ),
                    width: double.maxFinite,
                    child: Text(
                      "Wash your hands",
                      style: TextStyle(
                        // ✅ Apply whiteColor
                          color: theme.whiteColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(width * 0.04,
                                width * 0.04, width * 0.04, width * 0.01),
                            child: Column(children: <Widget>[
                              Text(
                                // ✅ Apply blackColor
                                "Practicing good hygiene is an important habit that helps prevent the spread of COVID-19. Make these CDC recommendations part of your routine:\n"
                                    "Wash your hands often with soap and water for at least 20 seconds, especially after you have been in a public place, or after blowing your nose, coughing, or sneezing."
                                    "It’s especially important to wash:\n"
                                    "Before eating or preparing food"
                                    "Before touching your face"
                                    "After using the restroom"
                                    "After leaving a public place"
                                    "After blowing your nose, coughing, or sneezing"
                                    "After handling your mask"
                                    "After changing a diaper"
                                    "After caring for someone who’s sick"
                                    "After touching animals or pets"
                                    "If soap and water are not readily available, use a hand sanitizer that contains at least 60% alcohol. Cover all surfaces of your hands with the sanitizer and rub them together until they feel dry."
                                    "Avoid touching your eyes, nose, and mouth with unwashed hands."
                                    "Visit the CDC website for guidelines on how to properly wash your hands and use hand sanitizer. And see our video below on how soap kills the coronavirus. There’s plenty of science behind this basic habit. “Soap molecules disrupt the fatty layer or coat surrounding the virus, ” says Dr. Goldberg. “Once the viral coat is broken down, the virus is no longer able to function."
                                    "In addition to hand-washing, disinfect frequently touched surfaces daily. This includes tables, doorknobs, light switches, countertops, handles, desks, phones, keyboards, toilets, faucets, and sinks.",
                                style: TextStyle(color: theme.blackColor),
                              ),
                            ]),
                          ),
                        ),
                      ],
                    ),
                    width: double.infinity,
                    decoration: BoxDecoration(),
                  ),
                  Image.asset(
                    'assets/safety/mask.gif',
                    width: width,
                    height: 250,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 5.0, right: 5.0),
                    padding: EdgeInsets.fromLTRB(4, 4, 4, 4),
                    decoration: BoxDecoration(
                      // ✅ Apply primaryColor
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(5.0),
                        right: Radius.circular(5.0),
                      ),
                    ),
                    width: double.maxFinite,
                    child: Text(
                      "Wear a mask",
                      style: TextStyle(
                        // ✅ Apply whiteColor
                          color: theme.whiteColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(width * 0.04,
                                width * 0.04, width * 0.04, width * 0.01),
                            child: Column(children: <Widget>[
                              Text(
                                // ✅ Apply blackColor
                                "Face masks have become essential accessories in protecting yourself and others from contracting COVID-19. The CDC recommends that people wear face coverings in public settings, especially since studies have shown that individuals with the novel coronavirus could be asymptomatic or presymptomatic. (Face masks, however, do not replace social distancing recommendations.)"
                                    "Face masks are designed to provide a barrier between your airway and the outside world,” says Dr. Ole Vielemeyer, medical director of Weill Cornell ID Associates and Travel Medicine in the Division of Infectious Diseases at NewYork-Presbyterian/Weill Cornell Medical Center and Weill Cornell Medicine. “By wearing a mask that covers your mouth and nose, you will reduce the risk of serving as the source of disease spread by trapping your own droplets in the mask, and also reduce the risk of getting sick via droplets that contain the coronavirus by blocking access to your own airways.",
                                style: TextStyle(color: theme.blackColor),
                              ),
                            ]),
                          ),
                        ),
                      ],
                    ),
                    width: double.infinity,
                    decoration: BoxDecoration(),
                  ),
                ],
              ),
            ),
          ),
        //)
    );
  }
}