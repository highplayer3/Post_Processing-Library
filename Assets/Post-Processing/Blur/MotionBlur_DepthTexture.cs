using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlur_DepthTexture : PostEffectsBase
{

    public Shader shader;
    private Matrix4x4 previousViewProjectionMatrix;
    private Camera _camera;

    [Range(0, 0.2f)]
    public float blurSize;

    private void OnEnable()
    {
        _camera = this.GetComponent<Camera>();
        _camera.depthTextureMode |= DepthTextureMode.Depth;
        previousViewProjectionMatrix = _camera.projectionMatrix * _camera.worldToCameraMatrix;
    }
    private void OnDisable()
    {
        _camera.depthTextureMode &= ~DepthTextureMode.Depth;
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        
        Material material = new Material(shader);
        material.SetMatrix("_PreviousViewProjectionMatrix", previousViewProjectionMatrix);
        material.SetFloat("_BlurSize", blurSize);
        Matrix4x4 currentViewProjectionMatrix = (_camera.projectionMatrix * _camera.worldToCameraMatrix);
        Matrix4x4 currentViewProjectionInverseMatrix = currentViewProjectionMatrix.inverse;
        material.SetMatrix("_CurrentViewProjectionInverseMatrix", currentViewProjectionInverseMatrix);
        previousViewProjectionMatrix = currentViewProjectionMatrix;


        Graphics.Blit(src, dest, material);
    }

}