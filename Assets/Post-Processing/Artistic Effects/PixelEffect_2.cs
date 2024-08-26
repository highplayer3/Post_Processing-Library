using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PixelEffect_2 : PostEffectsBase
{
    public Shader pixelEffectShader;
    private Material pixelEffectMaterial;
    public Material material
    {
        get
        {
            pixelEffectMaterial = CheckShaderAndCreateMaterial(pixelEffectShader, pixelEffectMaterial);
            return pixelEffectMaterial;
        }
    }

    [Range(1, 24)]
    public int pixelSize;
    public bool AddStrip;





    void OnRenderImage(RenderTexture sourceTexture, RenderTexture destTexture)
    {
        //着色器实例不为空，就进行参数设置
        if (material != null)
        {
            material.SetInt("_PixelSize", pixelSize);
            material.SetInt("_AddStrip", AddStrip ? 1 : 0);

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
