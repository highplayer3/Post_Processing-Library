using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OldTV : PostEffectsBase
{
    public Shader oldTVShader;
    private Material oldTVMaterial;
    public Material material
    {
        get
        {
            oldTVMaterial = CheckShaderAndCreateMaterial(oldTVShader, oldTVMaterial);
            return oldTVMaterial;
        }
    }

    //两个参数值
    [Range(0, 1)]
    public float expand = 0.7f;
    [Range(0, 1)]
    public float noiseIntensity = 0.3f;
    public int stripeIntensity = 500;//条纹强度



    void OnRenderImage(RenderTexture sourceTexture, RenderTexture destTexture)
    {
        //着色器实例不为空，就进行参数设置
        if (material != null)
        {
            //给Shader中的外部变量赋值
            material.SetFloat("_Expand", expand);
            material.SetFloat("_NoiseIntensity", noiseIntensity);
            material.SetInt("_StripeIntensity", stripeIntensity);


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
