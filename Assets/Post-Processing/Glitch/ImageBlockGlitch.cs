using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ImageBlockGlitch : PostEffectsBase
{
	public Shader imgBlockGlitchShader;
	private Material imgBlockGlitchMaterial;
	public Material material
	{
		get
		{
			imgBlockGlitchMaterial = CheckShaderAndCreateMaterial(imgBlockGlitchShader, imgBlockGlitchMaterial);
			return imgBlockGlitchMaterial;
		}
	}

	public int row1, row2, col1, col2;
	//[Range(0f, 20f)]
	//public float blockSize;
	[Range(0f, 100f)]
	public float speed;
	[Range(0f, 5f)]
	public float pow1, pow2;
	[Range(0f, 10f)]
	public float intensity1, intensity2;


	void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		if (material != null)
		{
			material.SetFloat("_Row1", row1);
			material.SetFloat("_Row2", row2);
			material.SetFloat("_Speed", speed);
			material.SetFloat("_Col1", col1);
			material.SetFloat("_Col2", col2);
			material.SetFloat("_Pow1", pow1);
			material.SetFloat("_Pow2", pow2);
			material.SetFloat("_Intensity1", intensity1);
			material.SetFloat("_Intensity2", intensity2);
			Graphics.Blit(src, dest, material);
		}
		else
		{
			Graphics.Blit(src, dest);
		}
	}
}
