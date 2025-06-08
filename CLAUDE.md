## Overview
The Google AI Edge Gallery is an experimental app that puts the power of cutting-edge Generative AI models directly into your hands, running entirely on your Android (available now) and iOS (coming soon) devices. Dive into a world of creative and practical AI use cases, all running locally, without needing an internet connection once the model is loaded. Experiment with different models, chat, ask questions with images, explore prompts, and more!

It’s sleek, easy to use, and demonstrates the full power of on-device AI. You can run Gemma 3n models (E2B and E4B) directly on your device, but not older models.

## Key Features
📱 Run Locally, Fully Offline: Experience the magic of GenAI without an internet connection. All processing happens directly on your device.
🤖 Choose Your Model: Easily switch between different models from Hugging Face and compare their performance.
🖼️ Ask Image: Upload an image and ask questions about it. Get descriptions, solve problems, or identify objects.
✍️ Prompt Lab: Summarize, rewrite, generate code, or use freeform prompts to explore single-turn LLM use cases.
💬 AI Chat: Engage in multi-turn conversations.
📊 Performance Insights: Real-time benchmarks (TTFT, decode speed, latency).
🧩 Bring Your Own Model: Test your local LiteRT .task models.
🔗 Developer Resources: Quick links to model cards and source code.

## Important note
Currently, this repo contains only the code for Android app. iOS app is not yet ready.

## Core Capabilities
### Ask Image (Image-to-Text)
Use multimodal models like Gemma 3N to get text descriptions of images.

From the Home Screen, tap "Ask Image".
Select a compatible multimodal model (e.g., Gemma 3N; download if necessary - see Model Management).
(Optional) Adjust inference parameters.
Click on the “+” sign and select an image from your device's gallery or take a new photo (app permissions for camera/storage may be required).
Once an image is selected, add a text prompt (e.g. “what’s in this image”, “solve the math problem for me”) then hit “Send”.
View the output, copy it, or see performance stats if desired.

### Prompt Lab (Single-Turn Tasks)
This capability allows you to perform various single-instance text tasks.

From the Home Screen, tap "Prompt Lab."
Select a model (download if necessary).
Choose a Task Template from the available options:
Freeform Prompt: Enter any instruction for the model.
Summarize Text: Provide text to be summarized.
Rewrite Tone: Input text and select a target tone (e.g., Formal, Casual).
Code Snippet: Describe a code function you want and select a language.
Input your text or choose from example prompts.
(Optional) Adjust inference parameters.
Tap the "Send/Generate" button.
View the output. You can copy the output and view performance stats if desired.


### AI Chat (Multi-Turn Conversations)
Engage in back-and-forth conversations with an LLM.

From the Home Screen, tap "AI Chat."
Select a model (download if necessary).
Type your message in the input field and send.
The model will respond, maintaining the context of the conversation.
(Optional) Adjust inference parameters.
View performance stats for each turn if desired.

## Model Management
### Downloading & Trying Models
When you select a capability, models compatible with that task are listed.
If a model isn't on your device, a "Download" button will be visible after you expand the model item. Tapping it will initiate the download.
Once downloaded, the button will change to "Try It”, allowing you to use the model.
Feel free to switch apps or lock your device. The download will continue in the background. We'll send a notification when it's done.

### Hugging Face Login & License Acknowledgement
Some models (e.g., Gemma 3) are gated and require you to log in with your Hugging Face (HF) account and agree to their specific license terms before downloading.
The app will prompt you to log in via a web browser flow when you attempt to download such a model.
Successfully logging in and accepting terms will allow the download to proceed. Your HF token is stored securely for future downloads.

### Viewing Performance Statistics
For LLM tasks, after the model generates a response, you can view performance metrics:

Look for a "Stats" button below the response.
Metrics typically include:
Time to First Token (TTFT)
Prefill Speed (tokens/s)
Decode Speed (tokens/s)
Latency (sec)

### Deleting Models
To delete a downloaded model, simply click on the delete icon next to the model in the model selection screen