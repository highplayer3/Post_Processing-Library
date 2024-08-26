using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PixelEffect_1 : PostEffectsBase
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

    //三个可调节的自定义参数
    [Range(1f, 1024f), Tooltip("屏幕每行将被均分为多少个像素块")]
    public float PixelNumPerRow = 580.0f;

    [Tooltip("自动计算平方像素所需的长宽比与否")]
    public bool AutoCalulateRatio = true;

    [Range(0f, 24f), Tooltip("此参数用于自定义长宽比")]
    public float Ratio = 1.0f;




    void OnRenderImage(RenderTexture sourceTexture, RenderTexture destTexture)
    {
        //着色器实例不为空，就进行参数设置
        if (material != null)
        {
            float pixelNumPerRow = PixelNumPerRow;
            //给Shader中的外部变量赋值
            material.SetVector("_Params", new Vector2(pixelNumPerRow,
                AutoCalulateRatio ? ((float)sourceTexture.width / (float)sourceTexture.height) : Ratio));

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
