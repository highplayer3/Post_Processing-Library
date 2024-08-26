using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OldTV : PostEffectsBase
{
    public Shader oldTVShader;
    private Material oldTVMaterial;
    public Material material
    {
        get
        {
            oldTVMaterial = CheckShaderAndCreateMaterial(oldTVShader, oldTVMaterial);
            return oldTVMaterial;
        }
    }

    //��������ֵ
    [Range(0, 1)]
    public float expand = 0.7f;
    [Range(0, 1)]
    public float noiseIntensity = 0.3f;
    public int stripeIntensity = 500;//����ǿ��



    void OnRenderImage(RenderTexture sourceTexture, RenderTexture destTexture)
    {
        //��ɫ��ʵ����Ϊ�գ��ͽ��в�������
        if (material != null)
        {
            //��Shader�е��ⲿ������ֵ
            material.SetFloat("_Expand", expand);
            material.SetFloat("_NoiseIntensity", noiseIntensity);
            material.SetInt("_StripeIntensity", stripeIntensity);


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
