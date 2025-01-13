--Cleaning Data in SQL Queries

Select *
From NashvilleHousing


--Change Sale Date Format

Select SaleDate, CONVERT(date, SaleDate)
From NashvilleHousing

Alter Table NashvilleHousing
Add SaleDateConverted date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(date, SaleDate)


--Populate Property Address Data for NULL Values

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing as a
Join NashvilleHousing as b
	On a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
From NashvilleHousing as a
Join NashvilleHousing as b
	On a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--checking above query was successful

select PropertyAddress
from NashvilleHousing
where PropertyAddress is null


-- Breaking out Addresses into Individual Columns (Address, City, State)
		--Breaking out Property Address

Select PropertyAddress
From NashvilleHousing

Select Substring(PropertyAddress, 1, Charindex(',' , PropertyAddress) -1) as Address
, Substring(PropertyAddress, Charindex(',' , PropertyAddress) +1, LEN(PropertyAddress)) as City 
From NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255)

Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255)

Update NashvilleHousing
Set PropertySplitAddress = Substring(PropertyAddress, 1, Charindex(',' , PropertyAddress) -1)

Update NashvilleHousing
Set PropertySplitCity = Substring(PropertyAddress, Charindex(',' , PropertyAddress) +1, LEN(PropertyAddress))

		--Breaking out Owner Address

Select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255)

Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255)

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant

Select SoldAsVacant,
	CASE When SoldAsVacant = 'Y' Then 'Yes'
		 When SoldAsVacant = 'N' Then 'No'
		 Else SoldAsVacant
		 End
From NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
						When SoldAsVacant = 'N' Then 'No'
						Else SoldAsVacant
						End


-- Remove Duplicates

With RowNumCTE AS(
Select *,
	ROW_NUMBER() Over (
	Partition by ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 Order by UniqueID) as row_num
From NashvilleHousing)
Select *
From RowNumCTE
Where row_num > 1

With RowNumCTE AS(
Select *,
	ROW_NUMBER() Over (
	Partition by ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 Order by UniqueID) as row_num
From NashvilleHousing)
Delete
From RowNumCTE
Where row_num > 1
