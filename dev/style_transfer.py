import torch
import PIL
from processing import *

def content_loss(content_features, img_features, content_weight):
    diff = content_features - img_features
    return content_weight * torch.sum(diff * diff)

def gram_matrices(features, normalize=True):
    """Calculate gram matrices (approximation of covariance matrix) for image features

    Args:
        features (tensor): shape NxCxHxW -- represents a batch of image features
        normalize (bool, optional): Whether or not to normalize the gram matrix. Defaults to True.

    Returns:
        tensor: gram matrices for each feature map
    """
    N, C, H, W = features.shape
    features = features.view(N, C, H * W)
    gram = features.bmm(features.permute(0, 2, 1)).contiguous()
    if normalize:
        gram /= (H * W * C)
    return gram

def style_loss(features, layer_indices, style_targets, style_weights):
    """Calculate style loss between the given image features on a set of layer indices

    Args:
        features (list of tensors): list of all feature tensors for the image
        layer_indices (list): list of indices -- which layers of the image features to use in our style loss
        style_targets (list of tensors): list of style image features we're comparing our image features to 
        style_weights (float): how much weight to give style loss at each layer
    """
    loss = 0
    for i in range(len(layer_indices)):
        feature_idx = layer_indices[i]
        feature_layer = features[feature_idx]
        diff = gram_matrices(feature_layer) - style_targets[i]
        loss += style_weights[i] * torch.sum(diff * diff)
    return loss

def tv_loss(img, tv_weight):
    """Calculate the total variation loss for an image

    Args:
        img (tensor): shape 1x3xHxW -- an RGB image
        tv_weight (float): how much weight to give tv loss
    """
    _, _, H, W = img.shape
    left = img[:, :, :, 1:W]
    right = img[:, :, :, 0:W - 1]
    up = img[:, :, 1:H, :]
    down = img[:, :, 0:H - 1, :]

    horizontal_diff = left - right
    vertical_diff = up - down
    return tv_weight * torch.sum(horizontal_diff * horizontal_diff) + torch.sum(vertical_diff * vertical_diff)

def style_transfer(content_img_path, style_img_path, content_size, style_size, content_layer, content_weight, style_layers, style_weights, tv_weight, num_iters, random_init=False):
    content_img = preprocess(PIL.Image.open(content_img_path))
    features = extract_features(content_img.view(1, 3, 224, 224))
    content_target = features[content_layer].clone()

    style_img = preprocess(PIL.Image.open(style_img_path))
    features = extract_features(style_img.view(1, 3, 224, 224))
    style_targets = []
    for idx in style_layers:
        style_targets.append(gram_matrices(features[idx].clone()))
    
    # if random, initialize new img to random noise
    if random_init:
        img = torch.Tensor(content_img.size()).uniform_(0, 1)
    else:
        img = content_img.clone()
    
    img.requires_grad_()
    lr = 3.0
    decayed_lr = .1
    decay_iter = num_iters - 20

    # set up optimizer for the minimum
    optim = torch.optim.Adam([img], lr=lr)

    for i in range(num_iters):
        if i < num_iters - 10:
            img.data.clamp_(-1.5, 1.5)
        optim.zero_grad()

        features = extract_features(img.view(1, 3, 224, 224))

        c_loss = content_loss(content_target, features[content_layer], content_weight)
        s_loss = style_loss(features, style_layers, style_targets, style_weights)
        t_loss = tv_loss(img.view(1, 3, 224, 224), tv_weight) 
        loss = c_loss + s_loss + t_loss

        print('iter=' + str(i))

        loss.backward(retain_graph=True)

        if i == decay_iter:
            optim = torch.optim.Adam([img], lr=decayed_lr)
        optim.step()

        if i % 50 == 0:
            plt.figure()
            plt.imshow(deprocess(img.data))
            plt.show()
    plt.figure()
    plt.imshow(deprocess(img.data))
    plt.show()


content_img_path = './django/static/samples/sample_selfie_1.jpg'
style_img_path = './django/static/vincentvangogh/Vincent_van_Gogh_100.jpg'
content_img = PIL.Image.open(content_img_path)
style_img = PIL.Image.open(style_img_path)
print(min(content_img.size))


params = {
    'content_img_path' : content_img_path,
    'style_img_path' : style_img_path,
    'content_size' : min(content_img.size),
    'style_size' : min(style_img.size),
    'content_layer' : 3,
    'content_weight' : 5e-2, 
    'style_layers' : (1, 4, 6, 7),
    'style_weights' : (2e4, 5e2, 1e1, 1e0),
    'tv_weight' : 5e-2,
    'num_iters' : 200
}

'''
params = {
    'content_img_path' : content_img_path,
    'style_img_path' : style_img_path,
    'content_size' : min(content_img.size),
    'style_size' : min(style_img.size),
    'content_layer' : 3,
    'content_weight' : 5e-2, 
    'style_layers' : (1, 4, 6, 7),
    'style_weights' : (20000, 500, 12, 1),
    'tv_weight' : 5e-2,
    'num_iters' : 500
}
'''

#100 is good
#368 is starry night

#a = torch.tensor([[1, 2], [3, 4]])
#b = torch.tensor([[1, 1], [1, 1]])
#print(content_loss(a, b, .5))


print(content_img,style_img)



style_transfer(**params)
