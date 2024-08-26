using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScreenWaterEffect : PostEffectsBase
{
    public Shader screenWaterShader;
    private Material screenWaterMaterial;
    public Material material
    {
        get
        {
            screenWaterMaterial = CheckShaderAndCreateMaterial(screenWaterShader, screenWaterMaterial);
            return screenWaterMaterial;
        }
    }

    private float curTime = 1.0f;
    public Texture2D screenWaterDropTex;

    [Range(5, 64), Tooltip("Distortion")]
    public float Distortion = 8.0f;
    [Range(0, 7), Tooltip("水滴在X坐标上的尺寸")]
    public float SizeX = 1f;
    [Range(0, 7), Tooltip("水滴在Y坐标上的尺寸")]
    public float SizeY = 0.5f;
    [Range(0, 10), Tooltip("水滴的流动速度")]
    public float DropSpeed = 3.6f;


    void OnRenderImage(RenderTexture sourceTexture, RenderTexture destTexture)
    {
        //着色器实例不为空，就进行参数设置
        if (material != null)
        {
            //时间的变化
            curTime += Time.deltaTime;
            //时间大于100，便置0，保证可以循环
            if (curTime > 100) curTime = 0;

            //设置Shader中其他的外部变量
            material.SetFloat("_CurTime", curTime);
            material.SetFloat("_Distortion", Distortion);
            material.SetFloat("_SizeX", SizeX);
            material.SetFloat("_SizeY", SizeY);
            material.SetFloat("_DropSpeed", DropSpeed);
            material.SetTexture("_ScreenWaterDropTex", screenWaterDropTex);

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
