using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Ascii : PostEffectsBase
{
    public Shader asciiShader;
    private Material asciiMaterial;
    public Material material
    {
        get
        {
            asciiMaterial = CheckShaderAndCreateMaterial(asciiShader, asciiMaterial);
            return asciiMaterial;
        }
    }

    public Color colorTint = Color.white;
    [Range(0, 1)]
    public float blendRatio = 1.0f;

    [Range(0.5f, 10.0f)]
    public float scaleFactor = 1.0f;


    void OnRenderImage(RenderTexture sourceTexture, RenderTexture destTexture)
    {
        //��ɫ��ʵ����Ϊ�գ��ͽ��в�������
        if (material != null)
        {
            //��Shader�е��ⲿ������ֵ
            material.color = colorTint;
            material.SetFloat("_Alpha", blendRatio);
            material.SetFloat("_Scale", scaleFactor);


            //����Դ����Ŀ����Ⱦ�����������ǵĲ���Ч��
            Graphics.Blit(sourceTexture, destTexture, material);
        }
        //��ɫ��ʵ��Ϊ�գ�ֱ�ӿ�����Ļ�ϵ�Ч�������������û��ʵ����Ļ��Ч��
        else
        {
            //ֱ�ӿ���Դ����Ŀ����Ⱦ����
            Graphics.Blit(sourceTexture, destTexture);
        }
    }
}
