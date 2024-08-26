using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Ascii : PostEffectsBase
{
    public Shader asciiShader;
    private Material asciiMaterial;
    public Material material
    {
        get
        {
            asciiMaterial = CheckShaderAndCreateMaterial(asciiShader, asciiMaterial);
            return asciiMaterial;
        }
    }

    public Color colorTint = Color.white;
    [Range(0, 1)]
    public float blendRatio = 1.0f;

    [Range(0.5f, 10.0f)]
    public float scaleFactor = 1.0f;


    void OnRenderImage(RenderTexture sourceTexture, RenderTexture destTexture)
    {
        //着色器实例不为空，就进行参数设置
        if (material != null)
        {
            //给Shader中的外部变量赋值
            material.color = colorTint;
            material.SetFloat("_Alpha", blendRatio);
            material.SetFloat("_Scale", scaleFactor);


            //拷贝源纹理到目标渲染纹理，加上我们的材质效果
            Graphics.Blit(sourceTexture, destTexture, material);
        }
        //着色器实例为空，直接拷贝屏幕上的效果。此情况下是没有实现屏幕特效的
        else
        {
            //直接拷贝源纹理到目标渲染纹理
            Graphics.Blit(sourceTexture, destTexture);
        }
    }
}
