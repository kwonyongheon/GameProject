using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Item : MonoBehaviour
{
    public enum Type { Ammo, Weapon }; // ������ ����
    public Type type; // ������ ���� ����
    public int value; // ������ ��

    private Rigidbody rigid; // ������ٵ� ������Ʈ
    private SphereCollider sphereCollider; // ���Ǿ� �ݶ��̴� ������Ʈ

    private void Awake()
    {
        rigid = GetComponent<Rigidbody>();
        sphereCollider = GetComponent<SphereCollider>();
    }

    private void Update()
    {
        transform.Rotate(Vector3.up * 10 * Time.deltaTime); // ������ ȸ��
    }
}
