import replicate
from app.config import settings
import time


class AIService:
    def __init__(self):
        replicate.api_token = settings.replicate_api_token

    def generate_sticker(self, image_url: str, prompt: str = "sticker"):
        try:
            output = replicate.run(
                "stability-ai/sdxl:39ed52f2a60c3b36b33e4db36d3adad20f4d67b92b5ef2d58ef7843cd71ceab7",
                input={
                    "prompt": f"high quality sticker, {prompt}",
                    "negative_prompt": "blurry, low quality",
                    "width": 512,
                    "height": 512,
                    "num_inference_steps": 30,
                },
            )
            return {"status": "success", "result_url": output[0] if output else None}
        except Exception as e:
            return {"status": "error", "message": str(e)}

    def generate_avatar(self, image_url: str, style: str = "anime"):
        style_prompts = {
            "anime": "anime character, cel shading style",
            "comic": "comic book style, illustrated",
            "hand_drawn": "hand drawn sketch style",
            "watercolor": "watercolor painting style",
            "cyberpunk": "cyberpunk style, neon colors",
        }

        prompt = style_prompts.get(style, "anime character")

        try:
            output = replicate.run(
                "stability-ai/sdxl:39ed52f2a60c3b36b33e4db36d3adad20f4d67b92b5ef2d58ef7843cd71ceab7",
                input={
                    "prompt": f"portrait avatar, {prompt}",
                    "negative_prompt": "blurry, low quality",
                    "width": 512,
                    "height": 512,
                    "num_inference_steps": 30,
                },
            )
            return {"status": "success", "result_url": output[0] if output else None}
        except Exception as e:
            return {"status": "error", "message": str(e)}

    def poll_generation(self, prediction_id: str):
        try:
            prediction = replicate.predictions.get(prediction_id)
            return {
                "status": prediction.status,
                "output": prediction.output if prediction.status == "succeeded" else None,
            }
        except Exception as e:
            return {"status": "error", "message": str(e)}
