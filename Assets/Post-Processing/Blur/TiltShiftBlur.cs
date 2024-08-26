using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TiltShiftBlur : PostEffectsBase
{

	public Shader tiltShiftBlurShader;
	private Material tiltShiftBlurMaterial;
	public Material material
	{
		get
		{
			tiltShiftBlurMaterial = CheckShaderAndCreateMaterial(tiltShiftBlurShader, tiltShiftBlurMaterial);
			return tiltShiftBlurMaterial;
		}
	}
	//ÿ�β�����ת�ľ���
	[Range(0f, 10f)]
	public float RotateDistance = 1;
	//�����İ뾶
	[Range(0f, 10f)]
	public float Radius = 1.0f;
	//����������
	[Range(1, 20)]
	public int SampleCount = 10;
	//��Ļ�ռ��ƫ��
	[Range(-0.5f, 0.5f)]
	public float Offset;

	[Range(1f, 5f)]
	public float Pow = 3;

	[Range(1f, 5f)]
	public float Area = 2;

	void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		if (material != null)
		{
			material.SetFloat("_RotateDistance", RotateDistance);
			material.SetInt("_SampleCount", SampleCount);
			material.SetFloat("_Radius", Radius);
			material.SetFloat("_Offset", Offset);
			material.SetFloat("_Pow", Pow);
			material.SetFloat("_Area", Area);

			Graphics.Blit(src, dest, material);
		}
		else
		{
			Graphics.Blit(src, dest);
		}
	}
}