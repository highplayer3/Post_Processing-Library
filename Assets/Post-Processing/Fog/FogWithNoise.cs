using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FogWithNoise : PostEffectsBase
{
    public enum Fog_Type
    {
        Linear_Height,
        Linear_Distance,
        Exponential_Height,
        Exponential_Distance,
        //Exponential_Squared_Height,
        //Exponential_Squared_Distance
    }

    public Shader fogShader;
    private Material fogMaterial = null;

    private Camera m_Camera;
    private Transform m_CameraTransform;
    public Camera camera
    {
        get
        {
            if (m_Camera == null)
            {
                m_Camera = GetComponent<Camera>();
            }
            return m_Camera;
        }
    }
    public Transform CameraTransform 
    {
        get
        {
            if (m_CameraTransform == null)
            {
                m_CameraTransform = camera.transform;
            }
            return m_CameraTransform;
        }
    }
    public Material material
    {
        get
        {
            fogMaterial = CheckShaderAndCreateMaterial(fogShader, fogMaterial);
            return fogMaterial;
        }
    }

    [Header("Fog Params")]
    public Fog_Type fog_Type = Fog_Type.Linear_Height;

    [Range(0.0f, 5.0f)]
    public float fogDensity = 1.0f;
    public Color fogColor = Color.white;
    public float fogStart = 0f;
    public float fogEnd = 2f;

    [Space(5),Header("Noise Params")]
    public Texture noiseTex;
    [Range(-1f, 1f)]
    public float fogXSpeed, fogYSpeed;
    [Range(0.0f, 3.0f)]
    public float noiseAmount = 1.0f;

    private void OnEnable()
    {
        camera.depthTextureMode |= DepthTextureMode.Depth;
    }
    private void OnDisable()
    {
        camera.depthTextureMode &= ~DepthTextureMode.Depth;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {
            Matrix4x4 frustumCorners = Matrix4x4.identity;

            float fov = camera.fieldOfView;
            float near = camera.nearClipPlane;
            float far = camera.farClipPlane;
            float aspect = camera.aspect;

            float halfHeight = near * Mathf.Tan(fov * 0.5f * Mathf.Deg2Rad);
            //aspectÎªºá×Ý±È
            Vector3 toRight = CameraTransform.right * halfHeight * aspect;
            Vector3 toTop = CameraTransform.up * halfHeight;

            Vector3 topLeft = CameraTransform.forward * near + toTop - toRight;
            float scale = topLeft.magnitude / near;

            topLeft.Normalize();
            topLeft *= scale;

            Vector3 topRight = CameraTransform.forward * near + toRight + toTop;
            topRight.Normalize();
            topRight *= scale;

            Vector3 bottomLeft = CameraTransform.forward * near - toRight - toTop;
            bottomLeft.Normalize();
            bottomLeft *= scale;

            Vector3 bottomRight = CameraTransform.forward * near + toRight - toTop;
            bottomRight.Normalize();
            bottomRight *= scale;

            frustumCorners.SetRow(0, bottomLeft);
            frustumCorners.SetRow(1, bottomRight);
            frustumCorners.SetRow(2, topRight);
            frustumCorners.SetRow(3, topLeft);

            material.SetMatrix("_FrustumCornersRay", frustumCorners);
            //material.SetMatrix("_ViewProjectionInverseMatrix", (camera.projectionMatrix * camera.worldToCameraMatrix).inverse);

            material.SetFloat("_FogDensity", fogDensity);
            material.SetColor("_FogColor", fogColor);
            material.SetFloat("_FogStart", fogStart);
            material.SetFloat("_FogEnd", fogEnd);

            material.SetTexture("_NoiseTex", noiseTex);
            material.SetFloat("_FogXSpeed", fogXSpeed);
            material.SetFloat("_FogYSpeed", fogYSpeed);
            material.SetFloat("_NoiseAmount", noiseAmount);

            Graphics.Blit(source, destination, material, (int)fog_Type);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
