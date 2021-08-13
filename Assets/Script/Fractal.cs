using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Fractal : MonoBehaviour
{
    Material m_material;
    public Vector4 m_param;
    Vector4 m_param_old;
    static string s_key = "_param";
    private void Awake()
    {
        m_material = GetComponent<Image>().material;

        Vector2 size = getSize();
        m_material.SetVector("_size", size);

        m_param = m_material.GetVector(s_key);
        m_param_old = m_param;
    }
    // Start is called before the first frame update
    void Start()
    {
        
    }

    Vector2 getSize()
    {
        return GetComponent<RectTransform>().rect.size;
    }

    Vector2 TexcoordToCalcPos(Vector2 texcoord)
    {
        // same as shader
        Vector2 _ScreenParams = new Vector2(Screen.width, Screen.height);
        Vector2 coord = _ScreenParams*(texcoord - new Vector2(0.5f, 0.5f));
        coord /= _ScreenParams.y;
        coord /= m_param.z;
        coord -= new Vector2(m_param.x, m_param.y);
        
        return coord;
    }

    // Update is called once per frame
    void Update()
    {
        if (m_param_old!= m_param)
        {
            m_material.SetVector(s_key, m_param);
            m_param_old = m_param;

        }
#if UNITY_EDITOR
        if (Input.GetMouseButtonDown(2))
        {
            m_param = m_material.GetVector(s_key);

            Vector2 clickpos = Input.mousePosition;
            Vector2 texcoord = new Vector2(clickpos.x / Screen.width, clickpos.y / Screen.height);

            Vector2 pos = TexcoordToCalcPos(texcoord);
            // calc new m_param.xy, to set TexcoordToCalcPos((0.5,0.5)) = pos
            Vector2 newParam = -pos;
            //newParam = Vector2.zero - newParam;

            m_param.x = newParam.x;
            m_param.y = newParam.y;
            //m_material.SetVector(s_key, m_param);



        }

        if (Input.GetKey(KeyCode.W) )
        {
            m_param = m_material.GetVector(s_key);

            m_param.z += m_param.z * 0.1f;
            //m_material.SetVector(s_key, m_param);
        }

        if (Input.GetKey(KeyCode.S))
        {
            m_param = m_material.GetVector(s_key);

            m_param.z -= m_param.z * 0.1f;
            //m_material.SetVector(s_key, m_param);
        }
#endif
    }
}
