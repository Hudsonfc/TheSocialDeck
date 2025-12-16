//
//  RiddleMeThisCards.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation

let allRiddleMeThisCards: [Card] = [
    // Classic Riddles
    Card(text: "I speak without a mouth and hear without ears. I have no body, but I come alive with wind. What am I?", category: "Classic", correctAnswer: "An echo"),
    Card(text: "The more you take, the more you leave behind. What am I?", category: "Classic", correctAnswer: "Footsteps"),
    Card(text: "I have cities, but no houses. I have mountains, but no trees. I have water, but no fish. What am I?", category: "Classic", correctAnswer: "A map"),
    Card(text: "What has keys but no locks, space but no room, and you can enter but not go inside?", category: "Classic", correctAnswer: "A keyboard"),
    Card(text: "I'm tall when I'm young, and short when I'm old. What am I?", category: "Classic", correctAnswer: "A candle"),
    Card(text: "What has hands but can't clap?", category: "Classic", correctAnswer: "A clock"),
    Card(text: "I'm found in the ground but not dirt. I can be a rock, a gem, or metal. What am I?", category: "Classic", correctAnswer: "Ore"),
    Card(text: "The person who makes it, sells it. The person who buys it, never uses it. The person who uses it, never knows they're using it. What is it?", category: "Classic", correctAnswer: "A coffin"),
    Card(text: "What goes up and never comes down?", category: "Classic", correctAnswer: "Your age"),
    Card(text: "I'm light as a feather, but the strongest person can't hold me for more than a few minutes. What am I?", category: "Classic", correctAnswer: "Breath"),
    
    // Logic Riddles
    Card(text: "A man is looking at a photograph of someone. His friend asks who it is. The man replies, 'Brothers and sisters, I have none. But that man's father is my father's son.' Who is in the photograph?", category: "Logic", correctAnswer: "His son"),
    Card(text: "A rooster lays an egg on top of a barn roof. Which way does it roll?", category: "Logic", correctAnswer: "Roosters don't lay eggs"),
    Card(text: "There are three houses. One is red, one is blue, and one is white. If the red house is to the left of the house in the middle, and the blue house is to the right of the house in the middle, where is the white house?", category: "Logic", correctAnswer: "In Washington, D.C."),
    Card(text: "A man walks into a bar and asks for a glass of water. The bartender pulls out a gun and points it at him. The man says 'thank you' and walks out. Why?", category: "Logic", correctAnswer: "The man had hiccups"),
    Card(text: "What belongs to you but others use it more than you do?", category: "Logic", correctAnswer: "Your name"),
    Card(text: "I am taken from a mine and shut up in a wooden case, from which I am never released, and yet I am used by almost everyone. What am I?", category: "Logic", correctAnswer: "Pencil lead"),
    Card(text: "The more there is, the less you see. What is it?", category: "Logic", correctAnswer: "Darkness"),
    Card(text: "What comes once in a minute, twice in a moment, but never in a thousand years?", category: "Logic", correctAnswer: "The letter M"),
    
    // Wordplay Riddles
    Card(text: "What word is spelled incorrectly in every single dictionary?", category: "Wordplay", correctAnswer: "Incorrectly"),
    Card(text: "What starts with 'e' and ends with 'e' but only has one letter in it?", category: "Wordplay", correctAnswer: "An envelope"),
    Card(text: "What has four wheels and flies?", category: "Wordplay", correctAnswer: "A garbage truck"),
    Card(text: "What word becomes shorter when you add two letters to it?", category: "Wordplay", correctAnswer: "Short"),
    Card(text: "I am a word of five letters. People eat me. If you remove my first letter, I become a form of energy. If you remove my first two letters, I become an animal. If you remove my first and last letters, I become a type of music. What am I?", category: "Wordplay", correctAnswer: "Wheat"),
    Card(text: "What building has the most stories?", category: "Wordplay", correctAnswer: "A library"),
    Card(text: "What has a neck but no head?", category: "Wordplay", correctAnswer: "A bottle"),
    
    // Mystery Riddles
    Card(text: "I'm always hungry, I must always be fed. The finger I touch will soon turn red. What am I?", category: "Mystery", correctAnswer: "Fire"),
    Card(text: "What can travel around the world while staying in a corner?", category: "Mystery", correctAnswer: "A stamp"),
    Card(text: "I have a head and a tail, but no body. What am I?", category: "Mystery", correctAnswer: "A coin"),
    Card(text: "What has a face but cannot see?", category: "Mystery", correctAnswer: "A clock"),
    Card(text: "I can be cracked, made, told, and played. What am I?", category: "Mystery", correctAnswer: "A joke"),
    Card(text: "I'm full of holes but still hold water. What am I?", category: "Mystery", correctAnswer: "A sponge"),
    Card(text: "What gets wetter and wetter the more it dries?", category: "Mystery", correctAnswer: "A towel"),
    
    // Nature Riddles
    Card(text: "I fall but I never get hurt. I pour but I'm not a jug. I help plants grow big and tall. What am I?", category: "Nature", correctAnswer: "Rain"),
    Card(text: "I'm always running but never get tired. I have a mouth but never talk. I have a bed but never sleep. What am I?", category: "Nature", correctAnswer: "A river"),
    Card(text: "I'm born in water but when I die I die because of water. What am I?", category: "Nature", correctAnswer: "Ice"),
    Card(text: "I have branches but no fruit, trunk, or leaves. What am I?", category: "Nature", correctAnswer: "A bank"),
    Card(text: "The more of me you take, the more you leave behind. What am I?", category: "Nature", correctAnswer: "Footsteps"),
    
    // Everyday Objects
    Card(text: "I have keys but no locks. I have space but no room. You can enter but not go inside. What am I?", category: "Objects", correctAnswer: "A keyboard"),
    Card(text: "I'm used to write, but I'm not a pen. I can be erased, but I'm not a mistake. What am I?", category: "Objects", correctAnswer: "A pencil"),
    Card(text: "I have a ring but no finger. What am I?", category: "Objects", correctAnswer: "A telephone"),
    Card(text: "What has a thumb and four fingers but is not alive?", category: "Objects", correctAnswer: "A glove"),
    Card(text: "I'm a box that holds keys without locks, yet my keys can unlock your soul. What am I?", category: "Objects", correctAnswer: "A piano"),
    Card(text: "What has one eye but can't see?", category: "Objects", correctAnswer: "A needle"),
    Card(text: "I have a spine but no bones. What am I?", category: "Objects", correctAnswer: "A book"),
    
    // Time & Numbers
    Card(text: "What is always in front of you but can't be seen?", category: "Time", correctAnswer: "The future"),
    Card(text: "What comes before but is never found?", category: "Time", correctAnswer: "Never"),
    
    // Food Riddles
    Card(text: "I'm yellow and curved, monkeys love me. What am I?", category: "Food", correctAnswer: "A banana"),
    Card(text: "I'm round, red, and sometimes green. I'm a fruit that's also a color. What am I?", category: "Food", correctAnswer: "An apple"),
    Card(text: "I'm white and you drink me. I come from cows. What am I?", category: "Food", correctAnswer: "Milk"),
    Card(text: "I'm a vegetable that's green and looks like a tree. What am I?", category: "Food", correctAnswer: "Broccoli"),
    Card(text: "I'm sweet and come in bars. I'm a treat that kids love. What am I?", category: "Food", correctAnswer: "Chocolate"),
    
    // Animal Riddles
    Card(text: "I'm a bird that can't fly, but I can swim really well. What am I?", category: "Animals", correctAnswer: "A penguin"),
    Card(text: "I'm the king of the jungle, but I'm not actually from the jungle. What am I?", category: "Animals", correctAnswer: "A lion"),
    Card(text: "I'm black and white, and I'm known for being stinky. What am I?", category: "Animals", correctAnswer: "A skunk"),
    Card(text: "I'm slow and carry my home on my back. What am I?", category: "Animals", correctAnswer: "A snail"),
    Card(text: "I have a trunk but I'm not a tree. I'm the largest land animal. What am I?", category: "Animals", correctAnswer: "An elephant"),
    Card(text: "I'm known for having nine lives. What am I?", category: "Animals", correctAnswer: "A cat"),
    Card(text: "I hop around and I'm known for my pouch. What am I?", category: "Animals", correctAnswer: "A kangaroo"),
    
    // Body Parts
    Card(text: "I help you see, but I can't see myself. What am I?", category: "Body", correctAnswer: "An eye"),
    Card(text: "You have two of me, and I help you hear. What am I?", category: "Body", correctAnswer: "An ear"),
    Card(text: "You use me to smell, and I'm in the middle of your face. What am I?", category: "Body", correctAnswer: "A nose"),
    
    // Transportation
    Card(text: "I have two wheels and you pedal me. What am I?", category: "Transportation", correctAnswer: "A bicycle"),
    Card(text: "I fly in the sky and have wings, but I'm not a bird. What am I?", category: "Transportation", correctAnswer: "An airplane"),
    Card(text: "I travel on tracks and make a choo-choo sound. What am I?", category: "Transportation", correctAnswer: "A train"),
    
    // Sports & Games
    Card(text: "I'm round and you kick me. I'm used in a popular sport. What am I?", category: "Sports", correctAnswer: "A soccer ball"),
    Card(text: "I'm a game you play with rackets and a net. What am I?", category: "Sports", correctAnswer: "Tennis"),
    Card(text: "You bounce me and try to put me through a hoop. What am I?", category: "Sports", correctAnswer: "A basketball"),
    
    // Weather & Sky
    Card(text: "I appear after rain in the sky. I'm colorful and curved. What am I?", category: "Nature", correctAnswer: "A rainbow"),
    Card(text: "I'm hot and bright. I shine during the day. What am I?", category: "Nature", correctAnswer: "The sun"),
    Card(text: "I'm white and fluffy, and I float in the sky. What am I?", category: "Nature", correctAnswer: "A cloud"),
    Card(text: "I twinkle in the night sky. What am I?", category: "Nature", correctAnswer: "A star"),
    
    // More Classic Riddles
    Card(text: "The more you take away, the larger I become. What am I?", category: "Classic", correctAnswer: "A hole"),
    Card(text: "I'm seen in water but I'm not wet. What am I?", category: "Classic", correctAnswer: "A reflection"),
    Card(text: "I'm always coming but never arrive. What am I?", category: "Classic", correctAnswer: "Tomorrow"),
    Card(text: "I have legs but can't walk. What am I?", category: "Classic", correctAnswer: "A chair"),
    Card(text: "I have no beginning, no end, and no middle. What am I?", category: "Classic", correctAnswer: "A circle"),
    Card(text: "I'm not alive, but I grow. I don't have lungs, but I need air. What am I?", category: "Classic", correctAnswer: "Fire"),
    
    // More Wordplay
    Card(text: "What has a bottom at the top?", category: "Wordplay", correctAnswer: "Your legs"),
    Card(text: "I'm tall when I'm sitting, but short when I'm standing. What am I?", category: "Wordplay", correctAnswer: "A dog"),
    Card(text: "What can you break without touching it?", category: "Wordplay", correctAnswer: "A promise"),
    Card(text: "What has words but never speaks?", category: "Wordplay", correctAnswer: "A dictionary"),
    Card(text: "I'm an odd number. Take away a letter and I become even. What number am I?", category: "Wordplay", correctAnswer: "Seven"),
    
    // More Mystery
    Card(text: "I'm invisible but I'm everywhere. You can't see me but you know I'm there. What am I?", category: "Mystery", correctAnswer: "Air"),
    Card(text: "I have no legs but I can travel far. I have no mouth but I can make sounds. What am I?", category: "Mystery", correctAnswer: "Wind"),
    Card(text: "I'm not alive, but I can die. What am I?", category: "Mystery", correctAnswer: "A battery"),
    Card(text: "I have a heart that doesn't beat. What am I?", category: "Mystery", correctAnswer: "An artichoke"),
    
    // More Objects
    Card(text: "I have teeth but I can't bite. What am I?", category: "Objects", correctAnswer: "A comb"),
    Card(text: "I'm made of glass but you can't see through me clearly. You look at yourself in me. What am I?", category: "Objects", correctAnswer: "A mirror"),
    Card(text: "I'm long and thin. I help you see better. What am I?", category: "Objects", correctAnswer: "Glasses"),
    Card(text: "I open but never close. I'm on your head. What am I?", category: "Objects", correctAnswer: "An umbrella"),
    Card(text: "I have pages but I'm not a book. I help you stay clean. What am I?", category: "Objects", correctAnswer: "A calendar"),
    Card(text: "I'm round and you bounce me. I'm used in many sports. What am I?", category: "Objects", correctAnswer: "A ball"),
]
