using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ComicBook : PostEffectsBase
{
    public Shader comicBookShader;
    private Material comicBookMaterial;
    public Material material
    {
        get
        {
            comicBookMaterial = CheckShaderAndCreateMaterial(comicBookShader, comicBookMaterial);
            return comicBookMaterial;
        }
    }

    [Tooltip("Strip orientation in radians.")]
    public float StripAngle = 0.6f;

    [Min(0f), Tooltip("Amount of strips to draw.")]
    public float StripDensity = 180f;

    [Range(0f, 1f), Tooltip("Thickness of the inner strip fill.")]
    public float StripThickness = 0.5f;

    public Vector2 StripLimits = new Vector2(0.25f, 0.4f);

    [ColorUsage(false)] public Color StripInnerColor = new Color(0.3f, 0.3f, 0.3f);

    [ColorUsage(false)] public Color StripOuterColor = new Color(0.8f, 0.8f, 0.8f);

    [ColorUsage(false)] public Color FillColor = new Color(0.1f, 0.1f, 0.1f);

    [ColorUsage(false)] public Color BackgroundColor = Color.white;

    [Range(0f, 1f), Tooltip("Blending factor.")]
    public float Amount = 1f;



    void OnRenderImage(RenderTexture sourceTexture, RenderTexture destTexture)
    {
        //着色器实例不为空，就进行参数设置
        if (material != null)
        {
            material.SetFloat("_StripCosAngle", Mathf.Cos(StripAngle / 180 * Mathf.PI));
            material.SetFloat("_StripSinAngle", Mathf.Sin(StripAngle / 180 * Mathf.PI));
            material.SetFloat("_StripLimitsMin", StripLimits.x);
            material.SetFloat("_StripLimitsMax", StripLimits.y);
            material.SetFloat("_StripDensity", StripDensity * 10f);
            material.SetFloat("_StripThickness", StripThickness);
            material.SetFloat("_Amount", Amount);
            material.SetColor("_StripInnerColor", StripInnerColor);
            material.SetColor("_StripOuterColor", StripOuterColor);

            material.SetColor("_FillColor", FillColor);
            material.SetColor("_BackgroundColor", BackgroundColor);


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
