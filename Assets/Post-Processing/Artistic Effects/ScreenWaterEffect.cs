using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScreenWaterEffect : PostEffectsBase
{
    public Shader screenWaterShader;
    private Material screenWaterMaterial;
    public Material material
    {
        get
        {
            screenWaterMaterial = CheckShaderAndCreateMaterial(screenWaterShader, screenWaterMaterial);
            return screenWaterMaterial;
        }
    }

    private float curTime = 1.0f;
    public Texture2D screenWaterDropTex;

    [Range(5, 64), Tooltip("Distortion")]
    public float Distortion = 8.0f;
    [Range(0, 7), Tooltip("ˮ����X�����ϵĳߴ�")]
    public float SizeX = 1f;
    [Range(0, 7), Tooltip("ˮ����Y�����ϵĳߴ�")]
    public float SizeY = 0.5f;
    [Range(0, 10), Tooltip("ˮ�ε������ٶ�")]
    public float DropSpeed = 3.6f;


    void OnRenderImage(RenderTexture sourceTexture, RenderTexture destTexture)
    {
        //��ɫ��ʵ����Ϊ�գ��ͽ��в�������
        if (material != null)
        {
            //ʱ��ı仯
            curTime += Time.deltaTime;
            //ʱ�����100������0����֤����ѭ��
            if (curTime > 100) curTime = 0;

            //����Shader���������ⲿ����
            material.SetFloat("_CurTime", curTime);
            material.SetFloat("_Distortion", Distortion);
            material.SetFloat("_SizeX", SizeX);
            material.SetFloat("_SizeY", SizeY);
            material.SetFloat("_DropSpeed", DropSpeed);
            material.SetTexture("_ScreenWaterDropTex", screenWaterDropTex);

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
