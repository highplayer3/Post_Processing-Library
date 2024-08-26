using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PixelEffect_2 : PostEffectsBase
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

    [Range(1, 24)]
    public int pixelSize;
    public bool AddStrip;





    void OnRenderImage(RenderTexture sourceTexture, RenderTexture destTexture)
    {
        //��ɫ��ʵ����Ϊ�գ��ͽ��в�������
        if (material != null)
        {
            material.SetInt("_PixelSize", pixelSize);
            material.SetInt("_AddStrip", AddStrip ? 1 : 0);

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
