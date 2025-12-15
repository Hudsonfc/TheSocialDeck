//
//  WhatsMySecretCards.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation

// All What's My Secret? cards organized by category
let allWhatsMySecretCards: [Card] = [
    // Party cards
    Card(text: "You must start every sentence with 'Actually'", category: "Party", cardType: nil),
    Card(text: "You can only answer questions with questions", category: "Party", cardType: nil),
    Card(text: "You must touch your nose before speaking", category: "Party", cardType: nil),
    Card(text: "You must compliment someone every 2 minutes", category: "Party", cardType: nil),
    Card(text: "You must say 'That's interesting' after every statement", category: "Party", cardType: nil),
    Card(text: "You must look at the ceiling when someone says your name", category: "Party", cardType: nil),
    Card(text: "You must count to 3 before responding to anyone", category: "Party", cardType: nil),
    Card(text: "You must repeat the last word someone says", category: "Party", cardType: nil),
    Card(text: "You must whisper whenever someone asks you a question", category: "Party", cardType: nil),
    Card(text: "You must stand up every time someone laughs", category: "Party", cardType: nil),
    Card(text: "You must end every sentence with '...right?'", category: "Party", cardType: nil),
    Card(text: "You must point at someone when they talk", category: "Party", cardType: nil),
    Card(text: "You must say 'Excuse me' before you speak", category: "Party", cardType: nil),
    Card(text: "You must nod twice after every statement", category: "Party", cardType: nil),
    Card(text: "You must clear your throat before answering", category: "Party", cardType: nil),
    
    // Wild cards
    Card(text: "You must use air quotes for everything you say", category: "Wild", cardType: nil),
    Card(text: "You must pretend to write notes whenever someone talks", category: "Wild", cardType: nil),
    Card(text: "You must hum a song whenever there's silence", category: "Wild", cardType: nil),
    Card(text: "You must speak only in questions", category: "Wild", cardType: nil),
    Card(text: "You must act surprised at everything", category: "Wild", cardType: nil),
    Card(text: "You must mirror whoever is speaking (copy their gestures)", category: "Wild", cardType: nil),
    Card(text: "You must speak in a whisper if someone else is whispering", category: "Wild", cardType: nil),
    Card(text: "You must speak as if you're giving a speech", category: "Wild", cardType: nil),
    Card(text: "You must end every statement with '...or am I wrong?'", category: "Wild", cardType: nil),
    Card(text: "You must only speak when someone makes eye contact with you", category: "Wild", cardType: nil),
    Card(text: "You must describe everything you're doing as you do it", category: "Wild", cardType: nil),
    Card(text: "You must sing your responses instead of speaking", category: "Wild", cardType: nil),
    Card(text: "You must use hand gestures for everything", category: "Wild", cardType: nil),
    
    // Social cards
    Card(text: "You must ask 'How does that make you feel?' after every story", category: "Social", cardType: nil),
    Card(text: "You must always agree with the last person who spoke", category: "Social", cardType: nil),
    Card(text: "You must disagree with the first person who speaks after you", category: "Social", cardType: nil),
    Card(text: "You must say someone's name before addressing them", category: "Social", cardType: nil),
    Card(text: "You must ask follow-up questions after every statement", category: "Social", cardType: nil),
    Card(text: "You must summarize what someone said before responding", category: "Social", cardType: nil),
    Card(text: "You must give relationship advice to everything", category: "Social", cardType: nil),
    Card(text: "You must relate everything back to yourself", category: "Social", cardType: nil),
    Card(text: "You must apologize before speaking", category: "Social", cardType: nil),
    Card(text: "You must say 'That reminds me...' before sharing", category: "Social", cardType: nil),
    Card(text: "You must validate everyone's feelings", category: "Social", cardType: nil),
    Card(text: "You must say 'Interesting point' after every opinion", category: "Social", cardType: nil),
    Card(text: "You must ask 'What do you think?' after everything you say", category: "Social", cardType: nil),
    Card(text: "You must reference something from earlier in the conversation", category: "Social", cardType: nil),
    
    // Actions cards
    Card(text: "You must snap your fingers before you speak", category: "Actions", cardType: nil),
    Card(text: "You must clap once after every joke", category: "Actions", cardType: nil),
    Card(text: "You must tap the table when someone asks you something", category: "Actions", cardType: nil),
    Card(text: "You must raise your hand before speaking", category: "Actions", cardType: nil),
    Card(text: "You must do jazz hands when excited", category: "Actions", cardType: nil),
    Card(text: "You must check your phone every 2 minutes", category: "Actions", cardType: nil),
    Card(text: "You must stretch whenever someone mentions time", category: "Actions", cardType: nil),
    Card(text: "You must adjust your position after every question", category: "Actions", cardType: nil),
    Card(text: "You must make a 'thinking' pose before answering", category: "Actions", cardType: nil),
    Card(text: "You must shrug before disagreeing", category: "Actions", cardType: nil),
    Card(text: "You must point up whenever you say 'yes'", category: "Actions", cardType: nil),
    Card(text: "You must point down whenever you say 'no'", category: "Actions", cardType: nil),
    Card(text: "You must cross your arms when listening", category: "Actions", cardType: nil),
    Card(text: "You must lean forward when someone tells a secret", category: "Actions", cardType: nil),
    
    // Behavior cards
    Card(text: "You must laugh at everything, even if it's not funny", category: "Behavior", cardType: nil),
    Card(text: "You must act confused when someone asks a direct question", category: "Behavior", cardType: nil),
    Card(text: "You must act overly enthusiastic about everything", category: "Behavior", cardType: nil),
    Card(text: "You must pretend to be texting when not talking", category: "Behavior", cardType: nil),
    Card(text: "You must look around suspiciously every minute", category: "Behavior", cardType: nil),
    Card(text: "You must yawn whenever someone tells a long story", category: "Behavior", cardType: nil),
    Card(text: "You must act like you didn't hear the first time", category: "Behavior", cardType: nil),
    Card(text: "You must pretend to check your reflection in your phone", category: "Behavior", cardType: nil),
    Card(text: "You must look at the door whenever someone mentions leaving", category: "Behavior", cardType: nil),
    Card(text: "You must act like you're taking mental notes", category: "Behavior", cardType: nil),
    Card(text: "You must smile extra wide when uncomfortable", category: "Behavior", cardType: nil),
    Card(text: "You must look at your hands when thinking", category: "Behavior", cardType: nil),
    Card(text: "You must glance at other people when they're not looking", category: "Behavior", cardType: nil),
    Card(text: "You must act like you're on a secret mission", category: "Behavior", cardType: nil),
]
