using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Item : MonoBehaviour
{
    public enum Type { Ammo, Weapon }; // 아이템 유형
    public Type type; // 아이템 유형 변수
    public int value; // 아이템 값

    private Rigidbody rigid; // 리지드바디 컴포넌트
    private SphereCollider sphereCollider; // 스피어 콜라이더 컴포넌트

    private void Awake()
    {
        rigid = GetComponent<Rigidbody>();
        sphereCollider = GetComponent<SphereCollider>();
    }

    private void Update()
    {
        transform.Rotate(Vector3.up * 10 * Time.deltaTime); // 아이템 회전
    }
}
