using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PixelEffect_1 : PostEffectsBase
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

    //�����ɵ��ڵ��Զ������
    [Range(1f, 1024f), Tooltip("��Ļÿ�н�������Ϊ���ٸ����ؿ�")]
    public float PixelNumPerRow = 580.0f;

    [Tooltip("�Զ�����ƽ����������ĳ�������")]
    public bool AutoCalulateRatio = true;

    [Range(0f, 24f), Tooltip("�˲��������Զ��峤���")]
    public float Ratio = 1.0f;




    void OnRenderImage(RenderTexture sourceTexture, RenderTexture destTexture)
    {
        //��ɫ��ʵ����Ϊ�գ��ͽ��в�������
        if (material != null)
        {
            float pixelNumPerRow = PixelNumPerRow;
            //��Shader�е��ⲿ������ֵ
            material.SetVector("_Params", new Vector2(pixelNumPerRow,
                AutoCalulateRatio ? ((float)sourceTexture.width / (float)sourceTexture.height) : Ratio));

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
