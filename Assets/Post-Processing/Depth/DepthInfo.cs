using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DepthInfo : PostEffectsBase
{
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
            //aspectΪ���ݱ�
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

            Graphics.Blit(source, destination, material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }

}
