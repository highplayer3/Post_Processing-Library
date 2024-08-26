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

    [Range(1, 5), Tooltip("�뾶��ֵ�������˵����Ĵ���")]
    public int RadiusValue = 3;



    void OnRenderImage(RenderTexture sourceTexture, RenderTexture destTexture)
    {
        //��ɫ��ʵ����Ϊ�գ��ͽ��в�������
        if (material != null)
        {
            //��Shader�е��ⲿ������ֵ
           // material.SetFloat("_ResolutionValue", ResolutionValue);
            material.SetInt("_Radius", RadiusValue);
            material.SetVector("_PSize", new Vector2(1f / (float)sourceTexture.width, 1f / (float)sourceTexture.height));


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
