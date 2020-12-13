import torch
import torchvision.transforms as transforms

# values obtained from https://pytorch.org/docs/stable/torchvision/models.html
TORCH_MEAN = [0.485, 0.456, 0.406]
TORCH_STD = [0.229, 0.224, 0.225]

# Does mobilenet/resnet_18 allow for different sizes?
NN_IMPUT_SIZE = 224

def preprocess(img):
    transform = transforms.Compose([
        transforms.Resize([NN_IMPUT_SIZE, NN_IMPUT_SIZE]),
        transforms.ToTensor(),
        transforms.Normalize(mean=TORCH_MEAN.tolist(), std=TORCH_STD.tolist())
    ])
    return transform(img)

def deprocess(img):
    