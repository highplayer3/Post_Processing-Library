using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class lrisBlur : PostEffectsBase
{

	public Shader lrisBlurShader;
	private Material lrisBlurMaterial;
	public Material material
	{
		get
		{
			lrisBlurMaterial = CheckShaderAndCreateMaterial(lrisBlurShader, lrisBlurMaterial);
			return lrisBlurMaterial;
		}
	}
	//每次采样旋转的距离
	[Range(0f, 10f)]
	public float RotateDistance = 1;
	//采样的半径
	[Range(0f, 10f)]
	public float Radius = 1.0f;
	//采样的数量
	[Range(1, 20)]
	public int SampleCount = 10;

	[Space(5)]
	[Header("Control The non-Blur Region")]
	[Range(1f, 5f)]
	public float Pow = 3;
	[Range(-0.5f, 0.5f)]
	public float OffsetX, OffsetY;
	[Range(1f, 5f)]
	public float Area = 2f;

	void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		if (material != null)
		{
			material.SetFloat("_RotateDistance", RotateDistance);
			material.SetInt("_SampleCount", SampleCount);
			material.SetFloat("_Radius", Radius);
			material.SetFloat("_Pow", Pow);
			material.SetVector("_Offset", new Vector2(OffsetX, OffsetY));
			material.SetFloat("_AreaSize", Area);

			Graphics.Blit(src, dest, material);
		}
		else
		{
			Graphics.Blit(src, dest);
		}
	}
}