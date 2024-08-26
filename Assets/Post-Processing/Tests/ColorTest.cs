using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ColorTest : PostEffectsBase
{

	public Shader testShader;
	[Header("Modify the threshold(BlackAndWhitePlus)")]
	[Range(0,1)]
	public float threshold;
	public Color shadowColor = Color.black;

	private Material testMat;
	public Material material
	{
		get
		{
			testMat = CheckShaderAndCreateMaterial(testShader, testMat);
			return testMat;
		}
	}

	void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		if (material != null)
		{
			material.SetFloat("_Threshold", threshold);
			material.SetColor("_ShadowColor", shadowColor);
			Graphics.Blit(src, dest, material);
		}
		else
		{
			Graphics.Blit(src, dest);
		}
	}
}