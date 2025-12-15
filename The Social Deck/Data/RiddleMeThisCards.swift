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
    Card(text: "What has hands but cannot clap?", category: "Time", correctAnswer: "A clock"),
    Card(text: "What is always in front of you but can't be seen?", category: "Time", correctAnswer: "The future"),
    Card(text: "What comes before but is never found?", category: "Time", correctAnswer: "Never"),
]
