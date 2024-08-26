using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OilPaintEffect_1 : PostEffectsBase
{
    public Shader oilPaintShader;
    private Material oilPaintMaterial;
    public Material material
    {
        get
        {
            oilPaintMaterial = CheckShaderAndCreateMaterial(oilPaintShader, oilPaintMaterial);
            return oilPaintMaterial;
        }
    }

    [Range(1, 5), Tooltip("半径的值，决定了迭代的次数")]
    public int RadiusValue = 3;



    void OnRenderImage(RenderTexture sourceTexture, RenderTexture destTexture)
    {
        //着色器实例不为空，就进行参数设置
        if (material != null)
        {
            //给Shader中的外部变量赋值
           // material.SetFloat("_ResolutionValue", ResolutionValue);
            material.SetInt("_Radius", RadiusValue);
            material.SetVector("_PSize", new Vector2(1f / (float)sourceTexture.width, 1f / (float)sourceTexture.height));


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
